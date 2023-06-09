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
#using scripts\zm\gametypes\_globallogic;

#insert scripts\shared\shared.gsh;

#precache("material", "white");

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: v0.1.0
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

	Version: 0.1.0
	- 3 and 5 maps support
	- Credits, sentence and social on bottom left
	- Simple keyboard and controller button support
*/

#namespace clientids;

REGISTER_SYSTEM("clientids", &__init__, undefined)

function __init__()
{
	// this is now handled in code ( not lan )
	// see s_nextScriptClientId
	level.clientid = 0;

	callback::on_start_gametype(&init);
	callback::on_connect(&on_player_connect);
	callback::on_spawned(&on_player_spawned);
	// Note: Don't lock the game on the state but at least get called on endgame challenges::registerChallengesCallback( "gameEnd",&MapvoteStart );
}

function init()
{
	MapvoteConfigurate();
	level.startMapvote = &MapvoteStart;
	level.custom_end_screen_original = level.custom_end_screen; // Note: Prevent overwrite of existing custom_end_screen
	level.custom_end_screen = &custom_end_screen; //Note: Working solution but with endgame text
}

function custom_end_screen()
{
	[[level.custom_end_screen_original]]();
	MapvoteStart();
}

/*

	// propper solution by replacing intermission in scripts\zm\_zm.gsc
	function intermission()
	{
		level.intermission = true;
		level notify( "intermission" );

		players = GetPlayers();
		for( i = 0; i < players.size; i++ )
		{
			players[i] SetClientThirdPerson( 0 );
			players[i] resetFov();

			players[i].health = 100; // This is needed so the player view doesn't get stuck
			players[i] thread [[level.custom_intermission]]();
			
			players[i] StopSounds();
		}

		MapvoteStart();
		wait( 5.25 );

		players = GetPlayers();
		for( i = 0; i < players.size; i++ )
		{
			players[i] clientfield::set( "zmbLastStand", 0 );
		}

		level thread zombie_game_over_death();
	}

*/

function MapvoteConfigurate()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	level.mapvote = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.mapvote["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "zm_zod zm_castle zm_island zm_stalingrad zm_genesis zm_cosmodrome zm_theater zm_cosmodrome zm_theater zm_moon zm_prototype zm_tomb zm_temple zm_factory zm_asylum");

	// Precache maps images
	maps_data = [];
	maps_data = BuildMapsData();

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
	setDvarIfNotInizialized("mv_excludedmaps", "");

	// Nota: It is on end game and lock the game in the state but it display a fully white screen
	// level waittill("sfade");
	// level thread MapvoteStart();
}

function on_player_connect()
{
	self.clientid = matchRecordNewPlayer(self);
	if (!isdefined(self.clientid) || self.clientid == -1)
	{
		self.clientid = level.clientid;
		level.clientid++; // Is this safe? What if a server runs for a long time and many people join/leave
	}

	/#
		PrintLn("client: " + self.name + " clientid: " + self.clientid);
	#/
}

function on_player_spawned() // Patch for blur effect persisting (TODO: This issue is a BO2 issue, i don't know if BO3 have the same bug)
{
	self endon("disconnect");
	level endon("game_ended");
	level flag::wait_till("initial_blackscreen_passed");
	//Note: Just for quick testing put level thread MapvoteStart(); here
	//level thread MapvoteStart();
	
	self setblur(0, 0);
}

function handlePlayerButtons()
{
	self endon("disconnect");
	level endon("mv_destroy_hud");
	while (true)
	{
		if (self AdsButtonPressed())
		{
			self notify("right");
			wait 0.2;
		}

		if (self AttackButtonPressed())
		{
			self notify("left");
			wait 0.2;
		}

		if (self UseButtonPressed() || self JumpButtonPressed() || self ReloadButtonPressed())
		{
			self notify("select");
			wait 0.2;
		}
		wait 0.02;
	}
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
	result = GetDvarString(dvar);
	return result != "";
}

// mv_client.gsc
function MapvotePlayerUI()
{
	self thread handlePlayerButtons();
	self setblur(getDvarFloat("mv_blur"), 1.5);

	scroll_color = getColor(getDvarString("mv_scrollcolor"));
	bg_color = getColor(getDvarString("mv_backgroundcolor"));
	// self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self CreateRectangle("CENTER", "CENTER", -220, -452, 205, 133, scroll_color, "white", 1, 0);
	boxes[1] = self CreateRectangle("CENTER", "CENTER", 0, -452, 205, 133, bg_color, "white", 1, 0);
	boxes[2] = self CreateRectangle("CENTER", "CENTER", 220, -452, 205, 133, bg_color, "white", 1, 0);

	self thread ClientFixAngle();
	level waittill("mv_start_animation");

	if (getDvarInt("mv_extramaps") == 1)
	{
		dynamic_position = 100;
		boxes[3] = self CreateRectangle("CENTER", "CENTER", -120, -452, 205, 133, bg_color, "white", 2, 0);
		boxes[4] = self CreateRectangle("CENTER", "CENTER", 120, -452, 205, 133, bg_color, "white", 2, 0);
		boxes[3] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[4] affectElement("y", 1.2, -50 + dynamic_position);
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

	self thread DestroyBoxes(boxes);
	self.statusicon = "uie_t7_hud_waypoints_compassping_enemy"; // Red dot
	level waittill("mv_start_vote");
	boxes[0] affectElement("alpha", 0.2, 1);
	boxes[1] affectElement("alpha", 0.2, 1);
	boxes[2] affectElement("alpha", 0.2, 1);
	if (boxes.size > 3)
	{
		boxes[3] affectElement("alpha", 0.2, 1);
		boxes[4] affectElement("alpha", 0.2, 1);
	}
	index = 0;
	isVoting = 1;
	while (level.mapvote["time"] > 0 && isVoting)
	{
		command = self util::waittill_any_return("left", "right", "select");
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
		select_color = getColor(GetDvarString("mv_selectcolor"));
		boxes[index] affectElement("color", 0.2, select_color);
		level waittill("mv_destroy_hud");
	}
}

function DestroyBoxes(boxes)
{
	level waittill("mv_destroy_hud");
	foreach (box in boxes)
	{
		box affectElement("alpha", 0.5, 0);
	}
	wait 0.5;
	foreach (box in boxes)
	{
		box hud::destroyElem();
	}
}

function ClientFixAngle() // TODO: Check if the bug happen also in BO3
{
	self endon("disconnect");
	level endon("game_ended");
	level waittill("mv_start_vote");
	angles = self getPlayerAngles();

	self util::waittill_any("left", "right");
	if (self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

// mv_server.gsc
function MapvoteGetMapsThatCanBeVoted(mapslist)
{
	if (GetDvarString("mv_excludedmaps") != "")
	{
		maps = [];
		maps = strTok(GetDvarString("mv_excludedmaps"), " ");
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
		index = RandomIntRange(0, mapsIDs.size);
		map = mapsIDs[index];
		mapschoosed[i] = map;
		logPrint("map;" + map + ";index;" + index + "\n");
		mapsIDs = ArrayRemoveElement(mapsIDs, map);
		// arrayremovevalue(mapsIDs, map);
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
		mapslist = [];
		maps_keys = [];
		maps_keys = strTok(GetDvarString("mv_maps"), " ");
		mapslist = MapvoteGetRandomMaps(maps_keys); // Remove blacklisted maps
		times = 3;
		if (getDvarInt("mv_extramaps") == 1)
		{
			times = 5;
		}

		mapschoosed = MapvoteGetRandomMaps(maps_keys, times);
		level.mapvote["map1"] = level.maps_data[mapschoosed[0]];
		level.mapvote["map2"] = level.maps_data[mapschoosed[1]];
		level.mapvote["map3"] = level.maps_data[mapschoosed[2]];

		if (getDvarInt("mv_extramaps") == 1)
		{
			level.mapvote["map4"] = level.maps_data[mapschoosed[3]];
			level.mapvote["map5"] = level.maps_data[mapschoosed[4]];
		}

		foreach (player in level.players)
		{
			if (!player util::is_bot())
				player thread MapvotePlayerUI();
		}
		wait 0.2;
		level thread MapvoteServerUI();

		VoteManager();
	}
	// Note: Don't get called at all [[level.onRoundEndGame]](winner);
	// Note: Don't lock the game on the state but at least get called on endgame [[level.onEndGame_stub]](winner);
}

function MapvoteServerUI()
{
	mv_arrowcolor = GetColor(getDvarString("mv_arrowcolor"));
	mv_votecolor = getDvarString("mv_votecolor");

	buttons = level hud::createServerFontString("objective", 2);
	buttons setText("^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]");
	buttons.hideWhenInMenu = 0;

	mapsUI = [];
	mapsUI[0] = spawnStruct();
	mapsUI[1] = spawnStruct();
	mapsUI[2] = spawnStruct();

	mapsUI[0].mapname = level CreateString(level.mapvote["map1"].mapname, "objective", 1.2, "CENTER", "CENTER", -220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[1].mapname = level CreateString(level.mapvote["map2"].mapname, "objective", 1.2, "CENTER", "CENTER", 0, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[2].mapname = level CreateString(level.mapvote["map3"].mapname, "objective", 1.2, "CENTER", "CENTER", 220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);

	if (getDvarInt("mv_extramaps") == 1)
	{
		buttons hud::setPoint("CENTER", "CENTER", 0, 150);
		mapsUI[3] = spawnStruct();
		mapsUI[4] = spawnStruct();

		mapsUI[3].mapname = level CreateString(level.mapvote["map4"].mapname, "objective", 1.2, "CENTER", "CENTER", -120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsUI[4].mapname = level CreateString(level.mapvote["map5"].mapname, "objective", 1.2, "CENTER", "CENTER", 120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	}
	else
	{
		buttons hud::setPoint("CENTER", "CENTER", 0, 100);
	}

	level notify("mv_start_animation");

	for (i = 0; i < mapsUI.size; i++)
	{
		map = mapsUI[i];
		dynamic_position = 0;
		if (mapsUI.size > 3 && i < 3)
		{
			dynamic_position = -50;
		}
		else if (mapsUI.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		map.mapname.alpha = 0;
		map.mapname affectElement("alpha", 1.6, 1);
		map.mapname.y = -9 + dynamic_position;
		if (isDefined(map.textbg))
		{
			map.textbg.y = 186 + dynamic_position;
		}
		//map.image affectElement("y", 1.2, 89 + dynamic_position);
	}

	wait 1;
	level notify("mv_start_vote");

	mv_sentence = GetDvarString("mv_sentence");
	mv_socialname = GetDvarString("mv_socialname");
	mv_sociallink = GetDvarString("mv_sociallink");
	credits = level hud::createServerFontString("objective", 1.2);
	credits hud::setPoint("BOTTOM_LEFT", "BOTTOM_LEFT", 15, -70);
	credits setText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);
	credits affectElement("alpha", 0.5, 1);

	timer = level hud::createServerFontString("objective", 2);
	timer hud::setPoint("TOP", "TOP", "CENTER", 30);
	timer setTimer(level.mapvote["time"]);
	wait level.mapvote["time"];
	level notify("mv_destroy_hud");
	// logPrint("mapvote//mv_ServerUI " + getTime()/1000 + "\n");

	foreach (map in mapsUI)
	{
		map.mapname affectElement("alpha", 0.4, 0);
		if (isDefined(map.textbg))
		{
			map.textbg affectElement("alpha", 0.4, 0);
		}
		//map.image affectElement("alpha", 0.4, 0);
	}

	credits affectElement("alpha", 0.5, 0);
	timer affectElement("alpha", 0.5, 0);

	buttons affectElement("alpha", 0.4, 0);

	foreach (player in level.players)
	{
		player notify("done");
		player setblur(0, 0);
	}
}

function VoteManager()
{
	votes = [];
	votes[0] = spawnStruct();
	votes[1] = spawnStruct();
	votes[2] = spawnStruct();
	votes[0].votes = level CreateString(0, "objective", 1.5, "LEFT", "CENTER", -150, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[0].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[0].map = level.mapvote["map1"];

	votes[1].votes = level CreateString(0, "objective", 1.5, "CENTER", "CENTER", 75, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[1].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[1].map = level.mapvote["map2"];

	votes[2].votes = level CreateString(0, "objective", 1.5, "RIGHT", "CENTER", 290, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[2].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[2].map = level.mapvote["map3"];
	if (getDvarInt("mv_extramaps") == 1)
	{
		votes[3] = spawnStruct();
		votes[4] = spawnStruct();
		votes[5] = spawnStruct();
		votes[3].votes = level CreateString(0, "objective", 1.5, "LEFT", "CENTER", -50, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[3].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[3].map = level.mapvote["map4"];

		votes[4].votes = level CreateString(0, "objective", 1.5, "RIGHT", "CENTER", 190, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[4].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[4].map = level.mapvote["map5"];
	}

	for (i = 0; i < votes.size; i++)
	{
		vote = votes[i];
		dynamic_position = 0;
		if (votes.size > 3 && i < 3)
		{
			dynamic_position = -50;
		}
		else if (votes.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		vote.value = 0;
		vote.votes.alpha = 0;
		vote.votes.y = 1 + dynamic_position;
		vote.votes affectElement("alpha", 1.6, 1);
	}

	isInVote = 1;
	index = 0;
	while (isInVote)
	{
		notify_value = level util::waittill_any_return("vote1", "vote2", "vote3", "vote4", "vote5", "mv_destroy_hud");

		if (notify_value == "mv_destroy_hud")
		{
			isInVote = 0; // Note: Required, seems that the break don't make the while quit.
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
			}
			votes[index].value++;
			votes[index].votes setValue(votes[index].value);
		}
	}

	foreach (vote in votes)
	{
		vote.votes affectElement("alpha", 0.5, 0);
	}

	winner = MapvoteGetMostVotedMap(votes);
	map = winner.map;
	MapvoteSetRotation(map.exec_rotation);

	wait 1.2;
}

function MapvoteGetMostVotedMap(votes)
{
	winner = spawnStruct();
	winner = votes[0];
	for (i = 1; i < votes.size; i++)
	{
		if (isDefined(votes[i]) && votes[i].value > winner.value)
		{
			winner = votes[i];
		}
	}

	return winner;
}

function MapvoteSetRotation(exec_rotation)
{
	setdvar("sv_maprotationcurrent", exec_rotation);
	setdvar("sv_maprotation", exec_rotation);
	level notify("mv_ended");
}

function insertMap(key, displayname, image, exec_rotation)
{
	/*
		key          : it rappresent that map id/key to use on the dvar mp_maps
		displayname : displayname3 its the mapname used for the 3 maps mapvote version
		image        : is the image shader to use for the map
		exec_rotation: it rappresent the value of sv_maprotationcurrent before map rotation get invoked
	*/
	level.maps_data[key] = SpawnStruct();
	level.maps_data[key].mapname = displayname;
	level.maps_data[key].exec_rotation = exec_rotation;
	level.maps_data[key].image = image;
}

function BuildMapsData()
{
	level.maps_data = [];
	insertMap("zm_zod", "Shadows Of Evil", "img_t7_menu_zm_preview_zod", "gametype zclassic map zm_zod");
	//Awakening
	insertMap("zm_castle", "Der Eisendrache", "img_t7_menu_zm_preview_castle", "gametype zclassic map zm_castle");
      //Eclipse
	insertMap("zm_island", "Zetsubou No Shima", "img_t7_menu_zm_preview_island", "gametype zclassic map zm_island");
      //Descent
	insertMap("zm_stalingrad", "Gorod Krovi", "img_t7_menu_zm_preview_stalingrad", "gametype zclassic map zm_stalingrad");
      //Salvation
	insertMap("zm_genesis", "Revelations", "img_t7_menu_zm_preview_stalingrad", "gametype zclassic map zm_genesis");
      //Chronicles
	insertMap("zm_cosmodrome", "Ascension", "img_t7_menu_zm_preview_cosmodrome", "gametype zclassic map zm_cosmodrome");
	insertMap("zm_theater", "Kino der Toten", "img_t7_menu_zm_preview_theater", "gametype zclassic map zm_theater");
	insertMap("zm_moon", "Moon", "img_t7_menu_zm_preview_moon", "gametype zclassic map zm_moon");
	insertMap("zm_prototype", "Nacht der Untoten", "img_t7_menu_zm_preview_prototype", "gametype zclassic map zm_prototype");
	insertMap("zm_tomb", "Origins", "img_t7_menu_zm_preview_tomb", "gametype zclassic map zm_tomb");
	insertMap("zm_temple", "Shangri-La", "img_t7_menu_zm_preview_tomb", "gametype zclassic map zm_temple");
	insertMap("zm_factory", "The Giant", "img_t7_menu_zm_preview_tomb", "gametype zclassic map zm_factory");
	insertMap("zm_asylum", "Verrückt", "img_t7_menu_zm_preview_tomb", "gametype zclassic map zm_asylum");

	/*
		To add a new map to the mapvote you need to edit this function called buildmaps_dataata.
		How to do it?
		1. Copy insertMap("", "",  "", ""); and paste it under level.maps_dataata = [];
		2. Compile the empty spaces, the arguments in ordare are:
			1) Map custom id: Is an id that you can use in your mv_maps dvar to identify this specific map
			2) Map UI name: Is the display name
			4) Map preview: Is the image to display on the mapvote
			5) Map config: This is the code that get executed once the map rotate to the winning map on the mapvote
		Let's make an exemple, i want to add a map called "Minecraft" so i'll add this code:
			insertMap("zm_minecraft", "Minecraft", "preview_zm_minecraft", "gametype zclassic exec minecraft.cfg map zm_minecraft");
	*/
	return level.maps_data;
}

function CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isValue)
{
	if (self != level)
	{
		hud = hud::createFontString(font, fontScale);
	}
	else
	{
		hud = hud::createServerFontString(font, fontScale);
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
function DrawShader(shader, x, y, width, height, color, alpha, sort, align, relative, isLevel)
{
	if (isDefined(isLevel))
		hud = newhudelem();
	else
		hud = newclienthudelem(self);
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = 1;
	hud.sort = sort;
	hud.children = [];
	if (isDefined(align))
		hud.align = align;
	if (isDefined(relative))
		hud.relative = relative;
	hud hud::setparent(level.uiparent);
	hud.x = x;
	hud.y = y;
	hud setshader(shader, width, height);
	hud.hideWhenInMenu = 0;
	hud.archived = 0;
	return hud;
}

function CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
	uiElement = newClientHudElem(self);
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
	uiElement hud::setParent(level.uiParent);
	uiElement setShader(shader, width, height);
	uiElement.hidden = false;
	uiElement.archived = false;
	uiElement hud::setPoint(align, relative, x, y);
	return uiElement;
}

function ValidateColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}

function GetColor(color)
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
	if (type == "x" || type == "y")
		self moveOverTime(time);
	else
		self fadeOverTime(time);
	if (type == "x")
		self.x = value;
	if (type == "y")
		self.y = value;
	if (type == "alpha")
		self.alpha = value;
	if (type == "color")
		self.color = value;
}

function GametypeToName(gametype)
{
	switch (tolower(gametype))
	{
	case "zclassic":
		return "zclassic";
	break;
	}
	return "invalid";
}

function ArrayRemoveElement(array, todelete)
{
	newarray = [];
	foreach (element in array)
	{
		if (element != todelete)
		{
			newarray[newarray.size] = element;
		}
	}
	return newarray;
}