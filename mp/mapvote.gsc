// TODO: Check whats using are not needed for the mapvote purpose
#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\math_shared;
#using scripts\shared\sound_shared;
#using scripts\shared\util_shared;
#using scripts\shared\drown;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\challenges_shared;
#using scripts\shared\util_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_shared;

#using scripts\shared\weapons\_weapon_utils;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\statstable_shared.gsh;

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: v0.0.0
	Config:
	set mv_enable			1 						// Enable/Disable the mapvote
	set mv_maps				""						// Lits of maps that can be voted on the mapvote, leave empty for all maps
	set mv_excludedmaps		""						// Lis of maps you don't want to show in the mapvote
	set mv_time 			1 						// Time to vote
	set mv_socialname 		"SocialName" 			// Name of the server social such as Discord, Twitter, Website, etc
	set mv_sentence 		"Thanks for playing" 	// Thankfull sentence
	set mv_votecolor		"5" 					// Color of the Vote Number
	set mv_arrowcolor		"white"					// RGB Color of the arrows
	set mv_selectcolor 		"lighgreen"				// RGB Color when map get voted
	set mv_backgroundcolor 	"grey"					// RGB Color of map background
	set mv_blur 			"3"						// Blur effect power
	set mv_gametypes 		"dm;dm.cfg"				// This dvar can be used to have multiple gametypes with different maps, with this dvar you can load gamemode cfg files

	TODO: List of supported features
*/

#namespace mapvote;

REGISTER_SYSTEM( "mapvote", &__init__, undefined )

function __init__()
{
    callback::on_start_gametype( &init );
    callback::on_connect( &on_player_connect );
    callback::on_spawned( &on_player_spawned );
}

function init()
{
    precacheStatusIcon("uie_t7_hud_waypoints_compassping_enemy");
    precacheStatusIcon("compassping_friendlyyelling_mp");
    precacheshader("ui_arrow_left");
    precacheshader("ui_arrow_right");

    precacheshader("white");
    MapvoteConfigurate();
}

function MapvoteConfigurate()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	level.mapvote = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.mapvote["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "");

	// PreCache maps images
	maps_data = [];
	maps_data = BuildMapsData();

	foreach (map in maps_data)
	{
		precacheshader(map.image);
	}

	// Setting default values if needed
	SetDvarIfNotInizialized("mv_credits", 1);
	SetDvarIfNotInizialized("mv_socials", 1);
	SetDvarIfNotInizialized("mv_extramaps", 1);
	SetDvarIfNotInizialized("mv_socialname", "Discord");
	SetDvarIfNotInizialized("mv_sociallink", "Discord.gg/^3xlabs^7");
	SetDvarIfNotInizialized("mv_sentence", "Thanks for Playing by @DoktorSAS");
	SetDvarIfNotInizialized("mv_votecolor", "5");
	SetDvarIfNotInizialized("mv_arrowcolor", "white");
	SetDvarIfNotInizialized("mv_blur", "3");
	SetDvarIfNotInizialized("mv_scrollcolor", "cyan");
	SetDvarIfNotInizialized("mv_selectcolor", "lightgreen");
	SetDvarIfNotInizialized("mv_backgroundcolor", "grey");
	SetDvarIfNotInizialized("mv_gametypes", "dm;dm.cfg tdm;tdm.cfg dm;dm.cfg tdm;tdm.cfg sd;sd.cfg sd;sd.cfg");
	setDvarIfNotInizialized("mv_excludedmaps", "");
}

function on_player_connect()
{
	
}

function on_player_spawned() // Patch for blur effect persisting (TODO: This issue is a BO2 issue, i don't know if BO3 have the same bug)
{
	self endon("disconnect");
	level endon("game_ended");
	self setblur(0, 0);
}

// utils.gsc
function SetDvarIfNotInizialized(dvar, value)
{
    if (!IsInizialized(dvar))
    {
        setDvar(dvar, value);
    }
}

function IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != "";
}

// mv_client.gsc
function MapvotePlayerUI()
{
	self setblur(getDvarFloat("mv_blur"), 1.5);

	scroll_color = getColor(getDvar("mv_scrollcolor"));
	bg_color = getColor(getDvar("mv_backgroundcolor"));
	self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self CreateRectangle("CENTER", "CENTER", -220, -50, 205, 131, scroll_color, "menu_zm_popup", 2, 0);
	boxes[1] = self CreateRectangle("CENTER", "CENTER", 0, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
	boxes[2] = self CreateRectangle("CENTER", "CENTER", 220, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);

	if(getDvarInt("mv_extramaps") == 1)
	{
		dynamic_position = 100;
		boxes[3] = self CreateRectangle("CENTER", "CENTER", -220, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
		boxes[4] = self CreateRectangle("CENTER", "CENTER", 0, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
		boxes[5] = self CreateRectangle("CENTER", "CENTER", 220, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
		boxes[3] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[4] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[5] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[0] affectElement("y", 1.2, -100);
		boxes[1] affectElement("y", 1.2, -100);
		boxes[2] affectElement("y", 1.2, -100);
	}
	else
	{
		boxes[0] affectElement("y", 1.2, -50);
		boxes[1] affectElement("y", 1.2, -50);
		boxes[2] affectElement("y", 1.2, -50);
	}
	

	self thread ClientFixAngle();
	self thread destroyBoxes(boxes);

	self notifyonplayercommand("left", "+attack");
	self notifyonplayercommand("right", "+speed_throw");
	self notifyonplayercommand("left", "+moveright");
	self notifyonplayercommand("right", "+moveleft");
	self notifyonplayercommand("select", "+usereload");
	self notifyonplayercommand("select", "+activate");
	self notifyonplayercommand("select", "+gostand");

	self.statusicon = "uie_t7_hud_waypoints_compassping_enemy"; // Red dot
	level waittill("mv_start_vote");
	boxes[0] affectElement("alpha", 0.2, 1);
	boxes[1] affectElement("alpha", 0.2, 1);
	boxes[2] affectElement("alpha", 0.2, 1);
	if(boxes.size > 3)
	{
		boxes[3] affectElement("alpha", 0.2, 1);
		boxes[4] affectElement("alpha", 0.2, 1);
		boxes[5] affectElement("alpha", 0.2, 1);
	}
	index = 0;
	isVoting = 1;
	while (level.__mapvote["time"] > 0 && isVoting)
	{
		command = self waittill_any_return("left", "right", "select");
		if (command == "right")
		{
			index++;
			if (index == boxes.size)
				index = 0;
		}
		else if (command == "left")
		{
			index--;
			if (index < 0)
				index = boxes.size - 1;
		}

		if (command == "select")
		{
			isVoting = 0;
		}
		else
		{
			for (i = 0; i < boxes.size; i++)
			{
				if (i != index)
					boxes[i] affectElement("color", 0.2, bg_color);
				else
					boxes[i] affectElement("color", 0.2, scroll_color);
			}
		}
	}
	if (!isVoting)
	{
		self.statusicon = "compassping_friendlyyelling_mp"; // Green dot
		vote = "vote" + (index + 1);
		level notify(vote);
		select_color = getColor(getDvar("mv_selectcolor"));
		boxes[index] affectElement("color", 0.2, select_color);
		level waittill("mv_destroy_hud");
	}
}

function DestroyBoxes(boxes)
{
	level endon("game_ended");
	level waittill("mv_destroy_hud");
	foreach (box in boxes)
	{
		box affectElement("alpha", 0.5, 0);
	}
	wait 0.5;
	foreach(box in boxes)
	{
		box destroyElem();
	}
}

function ClientFixAngle() // TODO: Check if the bug happen also in BO3 
{
	self endon("disconnect");
	level endon("game_ended");
	level waittill("mv_start_vote");
	angles = self getPlayerAngles();

	self waittill_any("left", "right");
	if (self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}


// mv_server.gsc

function MapvoteGetMapsThatCanBeVoted(mapslist)
{
	if (getDvar("mv_excludedmaps") != "")
	{
		maps = [];
		maps = strTok(getDvar("mv_excludedmaps"), " ");
		foreach (map in maps)
		{
			arrayremovevalue(mapslist, map);
		}
	}
	return mapslist;
}

function MapvoteGetRandomMaps(mapsIDs, times) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < times; i++)
	{
		index = randomIntRange(0, mapsIDs.size);
		map = mapsIDs[index];
		mapschoosed[i] = map;
		logPrint("map;"+map+";index;"+index+"\n");
		mapsIDs = ArrayRemoveElement(mapsIDs, map);
		//arrayremovevalue(mapsIDs, map);
	}

	return mapschoosed;
}

function MapvoteStart()
{
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;
		//mapslist = [];
		maps_keys = [];
		maps_keys = strTok(getDvar("mv_maps"), " ");
		mapslist = MapvoteGetRandomMaps(maps_keys); // Remove blacklisted maps
		times = 3;
		if(getDvarInt("mv_extramaps") == 1)
		{
			times = 6;
		}

		mapschoosed = MapvoteGetRandomMaps(maps_keys, times);
		level.mapvote["map1"] = level.maps_data[mapschoosed[0]];
		level.mapvote["map2"] = level.maps_data[mapschoosed[1]];
		level.mapvote["map3"] = level.maps_data[mapschoosed[2]];
		if(getDvarInt("mv_extramaps") == 1)
		{
			level.mapvote["map4"] = level.maps_data[mapschoosed[3]];
			level.mapvote["map5"] = level.maps_data[mapschoosed[4]];
			level.mapvote["map6"] = level.maps_data[mapschoosed[5]];
		}

		foreach (player in level.players)
		{
			//if (!player util::is_bot())
			//	player thread mv_PlayerUI();
		}
		wait 0.2;
		level thread MapvoteServerUI();

		VoteManager();
	}
}

function MapvoteServerUI()
{
	preCacheShader(level.mapvote["map1"].shader);
	preCacheShader(level.mapvote["map2"].shader);
	preCacheShader(level.mapvote["map3"].shader);

	if(isDefined(level.mapvote["map4"]))
	{
		preCacheShader(level.mapvote["map4"].shader);
		preCacheShader(level.mapvote["map5"].shader);
		preCacheShader(level.mapvote["map6"].shader);
	}

	mv_arrowcolor = GetColor(getDvar("mv_arrowcolor"));
	mv_votecolor = getDvar("mv_votecolor");

	buttons = level hud:createServerFontString("objective", 2);
	buttons setText("^7 ^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}] ^7");
	buttons.alpha = 0;
	buttons.hideWhenInMenu = 1;
	arrow_left = undefined;
	arrow_right = undefined;

	mapsUI = [];
	mapsUI[0] = spawnStruct();
	mapsUI[1] = spawnStruct();
	mapsUI[2] = spawnStruct();

	// map name
	mapsUI[0].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", -220, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[1].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", 0, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[2].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", 220, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[0].mapname.label = level.mapvote["map1"].mapname;
	mapsUI[1].mapname.label = level.mapvote["map2"].mapname;
	mapsUI[2].mapname.label = level.mapvote["map3"].mapname;

	// map preview
	mapsUI[0].image = level DrawShader(level.mapvote["map1"].image, -220, -310, 200, 117, (1, 1, 1), 1, 1, "LEFT", "CENTER", 1);
	mapsUI[0].image fadeovertime(0.5);
	mapsUI[1].image = level DrawShader(level.mapvote["map2"].image, 0, -310, 200, 117, (1, 1, 1), 1, 1, "CENTER", "CENTER", 1);
	mapsUI[1].image fadeovertime(0.5);
	mapsUI[2].image = level DrawShader(level.mapvote["map3"].image, 220, -310, 200, 117, (1, 1, 1), 1, 1, "RIGHT", "CENTER", 1);
	mapsUI[2].image fadeovertime(0.5);
	
	if(getDvarInt("mv_extramaps") == 1)
	{
		buttons setPoint("CENTER", "CENTER", 0, 150);
		arrow_right = level DrawShader("ui_scrollbar_arrow_right", 200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_scrollbar_arrow_left", -200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		mapsUI[3] = spawnStruct();
		mapsUI[4] = spawnStruct();
		mapsUI[5] = spawnStruct();
		
		// map name
		mapsUI[3].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", -220, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsUI[4].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", 0, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsUI[5].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", 220, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);

		mapsUI[3].mapname.label = level.mapvote["map4"].mapname;
		mapsUI[4].mapname.label = level.mapvote["map5"].mapname;
		mapsUI[5].mapname.label = level.mapvote["map6"].mapname;

		// map preview
		mapsUI[3].image = level DrawShader(level.mapvote["map4"].image, -220, -310, 200, 117, (1, 1, 1), 1, 1, "LEFT", "CENTER", 1);
		mapsUI[3].image fadeovertime(0.5);
		mapsUI[4].image = level DrawShader(level.mapvote["map5"].image, 0, -310, 200, 117, (1, 1, 1), 1, 1, "CENTER", "CENTER", 1);
		mapsUI[4].image fadeovertime(0.5);
		mapsUI[5].image = level DrawShader(level.mapvote["map6"].image, 220, -310, 200, 117, (1, 1, 1), 1, 1, "RIGHT", "CENTER", 1);
		mapsUI[5].image fadeovertime(0.5);

		level.mapvote["map1"].uistring = mapsUI[0].mapname;
		level.mapvote["map2"].uistring = mapsUI[1].mapname;
		level.mapvote["map3"].uistring = mapsUI[2].mapname;
		level.mapvote["map4"].uistring = mapsUI[3].mapname;
		level.mapvote["map5"].uistring = mapsUI[4].mapname;
		level.mapvote["map6"].uistring = mapsUI[5].mapname;


		// map name background - NOT WORKING BECAUSE OF HUD LIMITS
		//mapsUI[3].textbg = level DrawShader("black", -220, -325, 194, 30, (1, 1, 1), 0.7, 4, "LEFT", "CENTER", 1);
		//mapsUI[4].textbg = level DrawShader("black", 0, -325, 194, 30, (1, 1, 1), 0.7, 4, "CENTER", "CENTER", 1);
		//mapsUI[5].textbg = level DrawShader("black", 220, -325, 194, 30, (1, 1, 1), 0.7, 4, "RIGHT", "CENTER", 1);
	}
	else
	{
		// map name background
		mapsUI[0].textbg = level DrawShader("black", -220, -325, 194, 30, (1, 1, 1), 0.7, 4, "LEFT", "CENTER", 1);
		mapsUI[1].textbg = level DrawShader("black", 0, -325, 194, 30, (1, 1, 1), 0.7, 4, "CENTER", "CENTER", 1);
		mapsUI[2].textbg = level DrawShader("black", 220, -325, 194, 30, (1, 1, 1), 0.7, 4, "RIGHT", "CENTER", 1);

		buttons setPoint("CENTER", "CENTER", 0, 100);
        // TODO: Find equivalents icons to ui_scrollbar_arrow_right and ui_scrollbar_arrow_left from bo2 in bo3
		arrow_right = level DrawShader("ui_arrow_right", 200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_arrow_left", -200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
	}

	for(i = 0; i < mapsUI.size; i++) 
	{
		map = mapsUI[i];
		dynamic_position = 0;
		if(mapsUI.size > 3 && i < 3)
		{
			dynamic_position = -50;	
		}
		else if(mapsUI.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		map.mapname.alpha = 0;
		map.mapname affectElement("alpha", 1.6, 1);
		map.mapname.y = -14 + dynamic_position;
		if(isDefined(map.textbg))
		{
			map.textbg affectElement("y", 1.2, 176 + dynamic_position);
		}
		map.image affectElement("y", 1.2, 89 + dynamic_position);
	}
	
	buttons affectElement("alpha", 1.5, 0.8);

	wait 1;
	level notify("mv_start_vote");

	mv_sentence = getDvar("mv_sentence");
	mv_socialname = getDvar("mv_socialname");
	mv_sociallink = getDvar("mv_sociallink");
	credits = level createServerFontString("objective", 1.2);
	credits setPoint("BOTTOM_LEFT", "BOTTOM_LEFT");
	credits setText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);

	timer = level createServerFontString("objective", 2);
	timer setPoint("CENTER", "BOTTOM", "CENTER", "CENTER");
	timer setTimer(level.mapvote["time"]);
	wait level.mapvote["time"];
	level notify("mv_destroy_hud");
	// logPrint("mapvote//mv_ServerUI " + getTime()/1000 + "\n");

	foreach(map in mapsUI) 
	{
		map.mapname affectElement("alpha", 0.4, 0);
		if(isDefined(map.textbg))
		{
			map.textbg affectElement("alpha", 0.4, 0);
		}
		map.image affectElement("alpha", 0.4, 0);
	}
	
	credits affectElement("alpha", 0.5, 0);
	timer affectElement("alpha", 0.5, 0);

	buttons affectElement("alpha", 0.4, 0);
	arrow_right affectElement("alpha", 0.4, 0);
	arrow_left affectElement("alpha", 0.4, 0);

	foreach (player in level.players)
	{
		player notify("done");
		player setblur(0, 0);
	}
}

function VoteManager()
{
	votes = [];
	votes[0] = SpawnStruct();
	votes[1] = SpawnStruct();
	votes[2] = SpawnStruct();
	if(getDvarInt("mv_extramaps") == 1)
	{
		votes[3] = SpawnStruct();
		votes[4] = SpawnStruct();
		votes[5] = SpawnStruct();

		votes[0].votes = level.mapvote["map1"].uistring;
		votes[0].map = level.mapvote["map1"];

		votes[1].votes = level.mapvote["map2"].uistring;
		votes[1].map = level.mapvote["map2"];

		votes[2].votes = level.mapvote["map3"].uistring;
		votes[2].map = level.mapvote["map3"];

		votes[3].votes = level.mapvote["map4"].uistring;
		votes[3].map = level.mapvote["map4"];

		votes[4].votes = level.mapvote["map5"].uistring;
		votes[4].map = level.mapvote["map5"];

		votes[5].votes = level.mapvote["map6"].uistring;
		votes[5].map = level.mapvote["map6"];

		for(i = 0; i < votes.size; i++) 
		{
			vote = votes[i];
			vote.value = 0;
			vote.votes setValue(0);
		}
	}
	else
	{
		votes[0].votes = level CreateString(0, "objective", 1.5, "LEFT", "CENTER", -150, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[0].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[0].map = level.mapvote["map1"];

		votes[1].votes = level CreateString(0, "objective", 1.5, "CENTER", "CENTER", 75, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[1].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[1].map = level.mapvote["map2"];

		votes[2].votes = level CreateString(0, "objective", 1.5, "RIGHT", "CENTER", 290, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[2].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[2].map = level.mapvote["map3"];

		for(i = 0; i < votes.size; i++) 
		{
			vote = votes[i];
			vote.value = 0;
			vote.votes setValue(0);
			vote.votes affectElement("y", 1.2, -14);
		}
	}

	isInVote = 1;
	while (isInVote)
	{
		notify_value = level waittill_any_return("vote1", "vote2", "vote3", "vote4", "vote5", "vote6", "mv_destroy_hud");

		if (notify_value == "mv_destroy_hud")
		{
			break;
		}
		else
		{
			switch (notify_value)
			{
			case "vote1":
				index = 0;
				break;
			case "vote2":
				index = 1;
				break;
			case "vote3":
				index = 2;
				break;
			case "vote4":
				index = 3;
				break;
			case "vote5":
				index = 4;
				break;
			case "vote6":
				index = 5;
				break;
			}
			votes[index].value++;
			votes[index].votes setValue(votes[index].value);
		}
	}

	//winner = MapvoteGetMostVotedMap(votes);
	//map = winner.map;

	foreach(vote in votes) 
	{
		votes.votes affectElement("alpha", 0.5, 0);
	}

	MapvoteSetRotation(map.exec_rotation, map.gametype);

	wait 1.2;

}

function MapvoteSetRotation(mapid, gametype)
{
	array = strTok(gametype, ";");
	str = "";
	if (array.size > 1)
	{
		str = "exec " + array[1];
	}
	logPrint("mapvote//gametype//" + array[0] + "//executing//" + str + "\n");
	setdvar("g_gametype", array[0]);
	setdvar("sv_maprotationcurrent", str + " map " + mapid);
	setdvar("sv_maprotation", str + " map " + mapid);
	level notify("mv_ended");
}


function insert_map(key, displayname3, displayname6, image, exec_rotation)
{
    /*
        key          : it rappresent that map id/key to use on the dvar mp_maps
        displayname3 : displayname3 its the mapname used for the 3 maps mapvote version
        displayname6 : displayname6 its the mapname used for the 6 maps mapvote version (TODO: Check hud limites, we don't know if can support 6 maps)
        image        : is the image shader to use for the map
        exec_rotation: it rappresent the value of sv_maprotationcurrent before map rotation get invoked
    */
	level.maps_data[key] = SpawnStruct();
	if(getDvarInt("mv_extramaps") == 1)
	{
		level.maps_data[key].mapname = displayname6;
	}
	else
	{
		level.maps_data[key].mapname = displayname3;
	}
	
	level.maps_data[key].exec_rotation = exec_rotation;
	level.maps_data[key].image = image;
}

function BuildMapsData()
{
    level.maps_data = [];
    insertMap("mp_biodome", &"Aquarium", &"Aquarium - ", "img_t7_menu_mp_loadscreen_biodome", "mp_biodome"); 
    insertMap("mp_spire", &"Breach", &"Breach - ", "img_t7_menu_mp_loadscreen_spire", "mp_spire");
    insertMap("mp_sector", &"Combine", &"Combine - ", "img_t7_menu_mp_loadscreen_", "mp_sector");
    insertMap("mp_apartments", &"Evac", &"Evac - ", "img_t7_menu_mp_loadscreen_sector", "mp_apartments");
    insertMap("mp_chinatown", &"Exodus", &"Exodus - ", "img_t7_menu_mp_loadscreen_chinatown", "");
    insertMap("mp_veiled", &"Fringe", &"Fringe - ", "img_t7_menu_mp_loadscreen_veiled", "mp_veiled");
    insertMap("mp_havoc", &"Havoc", &"Havoc - ", "img_t7_menu_mp_loadscreen_havoc", "mp_havoc");
    insertMap("mp_ethiopia", &"Hunted", &"Hunted - ", "img_t7_menu_mp_loadscreen_ethiopia", "");
    insertMap("mp_infection", &"Infection", &"Infection - ", "img_t7_menu_mp_loadscreen_infection", "mp_infection");
    insertMap("mp_metro", &"Metro", &"Metro - ", "img_t7_menu_mp_loadscreen_metro", "mp_metro");
    insertMap("mp_redwood", &"Redwood", &"Redwood - ", "img_t7_menu_mp_loadscreen_redwood", "mp_redwood");
    insertMap("mp_stronghold", &"Stronghold", &"Stronghold - ", "img_t7_menu_mp_loadscreen_stronghold", "mp_stronghold");
    insertMap("mp_nuketown_x", &"Nuk3town", &"Nuk3town - ", "img_t7_menu_mp_loadscreen_nuketown_x", "mp_nuketown_x");


    // Awakening DLC
    insertMap("mp_crucible", &"Gauntlet", &"Gauntlet - ", "img_t7_menu_mp_loadscreen_crucible", "mp_crucible");
    insertMap("mp_rise", &"Rise", &"Rise - ", "img_t7_menu_mp_loadscreen_rise", "");
    insertMap("mp_skyjacked", &"Skyjacked", &"Skyjacked - ", "img_t7_menu_mp_loadscreen_skyjacked", "mp_skyjacked");
    insertMap("zm_factory", &"The Giant", &"The Giant - ", "img_t7_menu_mp_loadscreen_", "");
    insertMap("mp_waterpark", &"Splash", &"Splash - ", "img_t7_menu_mp_loadscreen_waterpark", "mp_waterpark");

    // Eclipse DLC
    insertMap("mp_kung_fu", &"Knockout", &"Knockout - ", "img_t7_menu_mp_loadscreen_kung_fu", "mp_kung_fu");
    insertMap("mp_conduit", &"Rift", &"Rift - ", "img_t7_menu_mp_loadscreen_conduit", "mp_conduit");
    insertMap("mp_aerospace", &"Spire", &"Spire - ", "img_t7_menu_mp_loadscreen_aerospace", "mp_aerospace");
    insertMap("mp_banzai", &"Verge", &"Verge - ", "img_t7_menu_mp_loadscreen_banzai", "mp_banzai");

    // Descent DLC
    insertMap("mp_shrine", &"Berserk", &"Berserk - ", "img_t7_menu_mp_loadscreen_shrine", "mp_shrine");
    insertMap("mp_cryogen", &"Cryogen", &"Cryogen - ", "img_t7_menu_mp_loadscreen_cryogen", "mp_cryogen");
    insertMap("mp_rome", &"Empire", &"Empire - ", "img_t7_menu_mp_loadscreen_rome", "mp_rome");
    insertMap("mp_arena", &"Rumble", &"Rumble - ", "img_t7_menu_mp_loadscreen_arena", "mp_arena");

    // Salvation DLC
    insertMap("mp_ruins", &"Citadel", &"Citadel - ", "img_t7_menu_mp_loadscreen_ruins", "mp_ruins");
    insertMap("mp_miniature", &"Micro", &"Micro - ", "img_t7_menu_mp_loadscreen_miniature", "mp_miniature");
    insertMap("mp_rome", &"Outlaw", &"Outlaw - ", "img_t7_menu_mp_loadscreen_rome", "mp_rome");
    insertMap("mp_city", &"Rupture", &"Rupture - ", "img_t7_menu_mp_loadscreen_city", "mp_city");

    // Bonus Maps
    insertMap("mp_veiled_heyday", &"Fringe Night", &"Fringe Night - ", "img_t7_menu_mp_loadscreen_veiled_heyday", "mp_veiled_heyday"); 
    insertMap("mp_redwood_ice", &"Redwood Snow", &"Redwood Snow - ", "img_t7_menu_mp_loadscreen_redwood_ice", "mp_redwood_ice"); 

    /*
		To add a new map to the mapvote you need to edit this function called buildmaps_dataata.
		How to do it? 
		1. Copy insertMap("", &"",  &" - ", "", ""); and paste it under level.maps_dataata = [];
		2. Compile the empty spaces, the arguments in ordare are:
			1) Map custom id: Is an id that you can use in your mv_maps dvar to identify this specific map
			2) Map UI name for 3 maps versio: It display this one if the dvar mv_extramaps is set to 0
			3) Map UI name for 6 maps versio: It display this one if the dvar mv_extramaps is set to 1
			4) Map preview: Is the image to display on the mapvote
			5) Map config: This is the code that get executed once the map rotate to the winning map on the mapvote
		Let's make an exemple, i want to add a map called "Home depot" so i'll add this code:
			insertMap("me_minecraft", &"Minecraft",  &"Minecraft - ", "loadscreen_me_minecraft", "exec minecraft.cfg map me_minecraft");
	*/
}

function CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isValue)
{
	if (self != level)
	{
		hud = self hud::createFontString(font, fontScale);
	}
	else
	{
		hud = level hud::createServerFontString(font, fontScale);
	}

	if (!isDefined(isValue))
	{
		hud setText(input);
	}
	else
	{
		hud setValue(int(input));
	}
		
	hud hud::setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.archived = 0;
	hud.hideWhenInMenu = 0;
	return hud;
}

function CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
    uiElement = newClientHudElem( self );
    uiElement.elemType = "bar";
    uiElement.width = width;
    uiElement.height = height;
    uiElement.align = align;
	uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.hidewheninmenu = true;
    uiElement.children = [];
    uiElement.sort = sort;
    uiElement.color = color;
    uiElement.alpha = alpha;
    uiElement hud::setParent( level.uiParent );
    uiElement setShader( shader, width , height );
    uiElement.hidden = false;
    uiElement.archived = false;
    uiElement hud::setPoint(align,relative,x,y);
    return uiElement;
}

function ValidateColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}

function  GetColor(color)
{
	switch (tolower(color))
	{
	case "red":
		return (0.960, 0.180, 0.180);

	case "black":
		return (0, 0, 0);

	case "grey":
		return (0.035, 0.059, 0.063);

	case "purple":
		return (1, 0.282, 1);

	case "pink":
		return (1, 0.623, 0.811);

	case "green":
		return (0, 0.69, 0.15);

	case "blue":
		return (0, 0, 1);

	case "lightblue":
	case "light blue":
		return (0.152, 0329, 0.929);

	case "lightgreen":
	case "light green":
		return (0.09, 1, 0.09);

	case "orange":
		return (1, 0662, 0.035);

	case "yellow":
		return (0.968, 0.992, 0.043);

	case "brown":
		return (0.501, 0.250, 0);

	case "cyan":
		return (0, 1, 1);

	case "white":
		return (1, 1, 1);

	}
}

function affectElement(type, time, value)
{
    if(type == "x" || type == "y")
        self moveOverTime(time);
    else
        self fadeOverTime(time);
    if(type == "x")
        self.x = value;
    if(type == "y")
        self.y = value;
    if(type == "alpha")
        self.alpha = value;
    if(type == "color")
        self.color = value;
}


function GametypeToName(gametype) 
{
	switch (tolower(gametype))
	{
	case "dm":
		return "Free for all";

	case "tdm":
		return "Team Deathmatch";
        
    case "ball":
		return "Uplink";

	case "sd":
		return "Search & Destroy";

    case "sr":
		return "Search & Rescue";

    case "dom":
		return "Domination";

	case "dem":
		return "Demolition";

	case "conf":
		return "Kill Confirmed";

	case "ctf":
		return "Capture the Flag";

	case "shrp":
		return "Sharpshooter";

	case "gun":
		return "Gun Game";
    
	case "sas":
		return "Sticks & Stones";

	case "hq":
		return "Headquaters";

	case "koth":
		return "Hardpoint";

	case "escort":
		return "Safeguard";

	case "clean":
		return "Fracture";

    case "prop":
		return "Prop Hunt";

    case "infect":
		return "Infected";

	case "sniperonly":
		return "Snipers Only";

	}
	return "invalid";
}

function ArrayRemoveElement(array, todelete)
{
	newarray = [];
	foreach(element in array) 
	{
		if(element != todelete)
		{
			newarray[newarray.size] = element;
		}
	}
	return newarray;
}