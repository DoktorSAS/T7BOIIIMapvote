#using scripts\codescripts\struct;
#using scripts\mp\gametypes\_globallogic_utils;

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

#insert scripts\shared\shared.gsh;

#precache("material", "white");
#precache("statusicon", "uie_t7_hud_waypoints_compassping_enemy");
#precache("statusicon", "compassping_friendlyyelling_mp");

// Base Maps
#precache("material", "img_t7_menu_mp_preview_biodome");
#precache("material", "img_t7_menu_mp_preview_spire");
#precache("material", "img_t7_menu_mp_preview_sector");
#precache("material", "img_t7_menu_mp_preview_apartments");
#precache("material", "img_t7_menu_mp_preview_chinatown");
#precache("material", "img_t7_menu_mp_preview_veiled");
#precache("material", "img_t7_menu_mp_preview_havoc");
#precache("material", "img_t7_menu_mp_preview_ethiopia");
#precache("material", "img_t7_menu_mp_preview_infection");
#precache("material", "img_t7_menu_mp_preview_metro");
#precache("material", "img_t7_menu_mp_preview_redwood");
#precache("material", "img_t7_menu_mp_preview_stronghold");
#precache("material", "img_t7_menu_mp_preview_nuketown_x");

// Awakening DLC
#precache("material", "img_t7_menu_mp_preview_crucible");
#precache("material", "img_t7_menu_mp_preview_rise");
#precache("material", "img_t7_menu_mp_preview_skyjacked");
#precache("material", "img_t7_menu_mp_preview_waterpark");

// Eclipse DLC
#precache("material", "img_t7_menu_mp_preview_kung_fu");
#precache("material", "img_t7_menu_mp_preview_conduit");
#precache("material", "img_t7_menu_mp_preview_aerospace");
#precache("material", "img_t7_menu_mp_preview_banzai");

// Descent
#precache("material", "img_t7_menu_mp_preview_shrine");
#precache("material", "img_t7_menu_mp_preview_cryogen");
#precache("material", "img_t7_menu_mp_preview_rome");
#precache("material", "img_t7_menu_mp_preview_arena");

// Salvation DLC
#precache("material", "img_t7_menu_mp_preview_ruins");
#precache("material", "img_t7_menu_mp_preview_miniature");
#precache("material", "img_t7_menu_mp_preview_western");
#precache("material", "img_t7_menu_mp_preview_city");

// Additional Maps
#precache("material", "img_t7_menu_mp_preview_veiled_heyday");
#precache("material", "img_t7_menu_mp_preview_redwood_ice");

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Contributors: luismrtnezz, Chenterito & rcv11x
	Version: Ezz Client
	Config:
	set mv_enable			1 						// Enable/Disable the mapvote
	set mv_maps				""						// List of maps that can be voted on the mapvote, leave empty for all maps
	set mv_excludedmaps		""						// List of maps you don't want to show in the mapvote
	set mv_time 			1 						// Time to vote
	set mv_socialname 		"SocialName" 			// Name of the server social such as Discord, Twitter, Website, etc
	set mv_sentence 		"Thanks for playing" 	// Thankful sentence
	set mv_votecolor		"5" 					// Color of the Vote Number
	set mv_arrowcolor		"white"					// RGB Color of the arrows
	set mv_selectcolor 		"lightgreen"		    // RGB Color when map get voted
	set mv_backgroundcolor 	"grey"					// RGB Color of map background
	set mv_blur 			"3"						// Blur effect power
	set mv_gametypes 		"tdm dom koth sd conf"  // This dvar can be used to have multiple gametypes with different maps, with this dvar you can load gamemode cfg files
	set mv_minplayers       1                       // Minimum players that must be on the server for map voting to be activated. 
    set mv_previews         0                       // Allow to display map previews (mod supported needed)
    
    Version: 0.1.0
	- 3 and 5 maps support
	- Credits, sentence and social on bottom left
	- Simple keyboard and controller button support
	- Allow to load gametypes

	Version: v1.0.0
	- Added map preview images through mod support
	- Allow to change vote
	- Included FastDL support 
	- Added GSC-based gametype gamesettings system

	Version: Ezz Client
	- Removed GSC-based gametype gamesettings system
	- Added a cleaner and more efficient gametype rotation system
	- Fixed issues with some dvars
	- Updated script file paths
	- Merged old scripts into one

*/

#namespace mapvote;

REGISTER_SYSTEM("mapvote", &__init__, undefined)

function __init__()
{
    callback::on_start_gametype(&init);
    callback::on_spawned(&on_player_spawned);
}

function init()
{
    MapvoteConfigurate();

    // MP sets this field after registering the final killcam, even if prematch ends immediately.
    while (!isDefined(level.inPrematchPeriod))
        wait 0.05;

    globallogic_utils::registerPostRoundEvent(&MapvoteStart);
}

function MapvoteConfigurate()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;                       // End if the mapvote its not enable

    level.mapvote = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.mapvote["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "mp_nuketown_x mp_skyjacked mp_stronghold mp_redwood mp_sector");

	SetDvarIfNotInizialized("mv_previews", 1);
    
    // PreCache maps images
	BuildMapsData();

	// Setting default values if needed
	SetDvarIfNotInizialized("mv_credits", 1);
	SetDvarIfNotInizialized("mv_socials", 1);
	SetDvarIfNotInizialized("mv_extramaps", 1);
	SetDvarIfNotInizialized("mv_socialname", "^7Discord");
	SetDvarIfNotInizialized("mv_sociallink", "^5discord.gg/xlabs");
	SetDvarIfNotInizialized("mv_sentence", "Thanks for playing");
	SetDvarIfNotInizialized("mv_votecolor", "5");
	SetDvarIfNotInizialized("mv_arrowcolor", "white");
	SetDvarIfNotInizialized("mv_blur", "3");
	SetDvarIfNotInizialized("mv_scrollcolor", "cyan");
	SetDvarIfNotInizialized("mv_selectcolor", "lightgreen");
	SetDvarIfNotInizialized("mv_backgroundcolor", "grey");
	SetDvarIfNotInizialized("mv_gametypes", "tdm dom koth sd"); // Add the ones you want to appear
	setDvarIfNotInizialized("mv_excludedmaps", "");
    SetDvarIfNotInizialized("mv_minplayers", 1);

    // Note: It is on end game and lock the game in the state but it display a fully white screen
	// level waittill("sfade");
	// level thread MapvoteStart();

}

function on_player_spawned()
{
	self endon("disconnect");
	level endon("game_ended");
	// Note: Just for quit testing put level thread MapvoteStart(); here
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

            while (self AdsButtonPressed())
            {
                wait 0.05;
            }
        }
        else if (self AttackButtonPressed())
        {
            self notify("left");

            while (self AttackButtonPressed())
            {
                wait 0.05;
            }
        }
        else if (self UseButtonPressed() ||
                 self JumpButtonPressed() ||
                 self ReloadButtonPressed())
        {
            self notify("select");

            while (self UseButtonPressed() ||
                   self JumpButtonPressed() ||
                   self ReloadButtonPressed())
            {
                wait 0.05;
            }
        }

        wait 0.05;
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

function MapvotePlayerUI()
{
    self setblur(getDvarFloat("mv_blur"), 1.5);

	scroll_color = getColor(getDvarString("mv_scrollcolor"));
	bg_color = getColor(getDvarString("mv_backgroundcolor"));
	boxes = [];
	boxes[0] = self CreateRectangle("CENTER", "CENTER", -220, -452, 205, 133, scroll_color, "white", 1, 0);
	boxes[1] = self CreateRectangle("CENTER", "CENTER", 0, -452, 205, 133, bg_color, "white", 1, 0);
	boxes[2] = self CreateRectangle("CENTER", "CENTER", 220, -452, 205, 133, bg_color, "white", 1, 0);

    previews = [];
    if(getDvarInt("mv_previews") == 1)
    {
        previews[0] = self DrawShader( level.mapvote["map1"].image, -220, -468, 197, 96, (1, 1, 1), 1, 3, "CENTER", "CENTER" );
        previews[1] = self DrawShader( level.mapvote["map2"].image,    0, -468, 197, 96, (1, 1, 1), 1, 3, "CENTER", "CENTER" );
        previews[2] = self DrawShader( level.mapvote["map3"].image,  220, -468, 197, 96, (1, 1, 1), 1, 3, "CENTER", "CENTER" );

        if (getDvarInt("mv_extramaps") == 1)
        {
            previews[3] = self DrawShader( level.mapvote["map4"].image, -120, -468, 197, 96, (1, 1, 1), 1, 3, "CENTER", "CENTER" );
            previews[4] = self DrawShader( level.mapvote["map5"].image,  120, -468, 197, 96, (1, 1, 1), 1, 3, "CENTER", "CENTER" );
        }

        foreach (preview in previews)
        {
            preview.alpha = 0;
        }
    }

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

    if(getDvarInt("mv_previews") == 1)
    {
    	// TODO: Instead of setting y in a for loop its better use affectElement instead
        for (i = 0; i < previews.size; i++)
        {
            if (isDefined(previews[i]))
            {
                if (previews.size > 3)
                {
                    if (i < 3)
                    {
                        previews[i].y = -116;
                    }
                    else
                    {
                        previews[i].y = 34;
                    }
                }
                else
                {
                    previews[i].y = -66;
                }
            }
        }
    }

	self thread DestroyBoxes(boxes, previews);
    self thread handlePlayerButtons();
	level waittill("mv_start_vote");

    foreach (box in boxes)
    {
        box affectElement("alpha", 0.2, 1);
    }

    if(getDvarInt("mv_previews") == 1)
    {
        foreach (preview in previews)
        {
            preview affectElement("alpha", 0.2, 1);
        }
    }

	index = 0;
	previuesindex = -1;
	select_color = GetColor(GetDvarString("mv_selectcolor"));

	while (true)
	{
	    command = self util::waittill_any_return("left", "right", "select", "done");

	    if (command == "done")
	    {
	        break;
	    }

	    // Move the selection to the right.
	    if (command == "right")
	    {
	        index++;

	        if (index >= boxes.size)
	        {
	            index = 0;
	        }
	    }
	    // Move the selection to the left.
	    else if (command == "left")
	    {
	        index--;

	        if (index < 0)
	        {
	            index = boxes.size - 1;
	        }
	    }
	    // Register or change the vote.
	    if (command == "select")
	    {
	        if (previuesindex != index)
	        {
	        	// Clear previous selection.
	            if (previuesindex >= 0)
	            {
	            	boxes[previuesindex] affectElement("color", 0.2, bg_color);
	            }

	            previuesindex = index;

	            boxes[index] affectElement("color", 0.2, select_color);

	            self.mv_vote = index;
	            level notify("mv_vote_cast");

	            wait 0.05;
	        }
	    }
        else
        {
        	// Update the selection indicator while scrolling.
            for (i = 0; i < boxes.size; i++)
            {
                if (i != index)
                {
                    boxes[i] affectElement("color", 0.2, bg_color);
                }
                else
                {
                    boxes[i] affectElement("color", 0.2, scroll_color);
                }
            }
        }
    }
}

function DestroyBoxes(boxes, previews)
{
    level waittill("mv_destroy_hud");

    foreach (box in boxes)
    {
        if (isDefined(box))
        {
            box affectElement("alpha", 0.5, 0);
        }
    }

    if (getDvarInt("mv_previews") == 1)
    {
        foreach (preview in previews)
        {
            if (isDefined(preview))
            {
                preview.alpha = 0;
            }
        }
    }

    wait 0.5;

    foreach (box in boxes)
    {
        if (isDefined(box))
        {
            box hud::destroyElem();
        }
    }

    if (getDvarInt("mv_previews") == 1)
    {
        foreach (preview in previews)
        {
            if (isDefined(preview))
            {
                preview hud::destroyElem();
            }
        }
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
		// logPrint("map;" + map + ";index;" + index + "\n");
		mapsIDs = ArrayRemoveElement(mapsIDs, map);
		// arrayremovevalue(mapsIDs, map);
	}

	return mapschoosed;
}

// Note: is required for  [[level.onEndGame_stub]](winner);  or [[level.onRoundEndGame_stub]](winner); -> function MapvoteStart(winner)
function MapvoteStart()
{
    if (isDefined(level.sidebet) && level.sidebet)
        return;

    if (!util::wasLastRound() || isDefined(level.mv_rotation_queued))
        return;

    if (getDvarInt("mv_enable") != 1 || GetRealPlayers() < getDvarInt("mv_minplayers"))
    {
        level.mv_rotation_queued = true;
        PrepareFallbackCfg();
        return;
    }

	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;
		// mapslist = [];
		maps_keys = [];
		maps_keys = strTok(GetDvarString("mv_maps"), " ");
		times = 3;
		if (getDvarInt("mv_extramaps") == 1)
		{
			times = 5;
		}

		mapschoosed = MapvoteGetRandomMaps(maps_keys, times);

		gametypes = [];
		gametypes = strTok(getDvarString("mv_gametypes"), " ");
		level.mapvote["map1"] = level.maps_data[mapschoosed[0]];
		level.mapvote["map2"] = level.maps_data[mapschoosed[1]];
		level.mapvote["map3"] = level.maps_data[mapschoosed[2]];

		level.mapvote["map1"].gametype = gametypes[RandomIntRange(0, gametypes.size)];
		level.mapvote["map2"].gametype = gametypes[RandomIntRange(0, gametypes.size)];
		level.mapvote["map3"].gametype = gametypes[RandomIntRange(0, gametypes.size)];

		level.mapvote["map1"].gametypeUI = GetGametypeDisplayName(level.mapvote["map1"].gametype);
		level.mapvote["map2"].gametypeUI = GetGametypeDisplayName(level.mapvote["map2"].gametype);
		level.mapvote["map3"].gametypeUI = GetGametypeDisplayName(level.mapvote["map3"].gametype);

		if (getDvarInt("mv_extramaps") == 1)
		{
			level.mapvote["map4"] = level.maps_data[mapschoosed[3]];
			level.mapvote["map5"] = level.maps_data[mapschoosed[4]];
			level.mapvote["map4"].gametype = gametypes[RandomIntRange(0, gametypes.size)];
			level.mapvote["map5"].gametype = gametypes[RandomIntRange(0, gametypes.size)];
			level.mapvote["map4"].gametypeUI = GetGametypeDisplayName(level.mapvote["map4"].gametype);
			level.mapvote["map5"].gametypeUI = GetGametypeDisplayName(level.mapvote["map5"].gametype);
		}

		foreach (player in level.players)
		{
		    if (!player util::is_bot())
		    {
		        player.mv_vote = -1;
		        player thread MapvotePlayerUI();
		    }
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
    buttons setText("^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to vote / change vote              ^3[{+attack}]");
    buttons.hideWhenInMenu = 0;

    mapsUI = [];
    mapsUI[0] = spawnStruct();
    mapsUI[1] = spawnStruct();
    mapsUI[2] = spawnStruct();

    mapsUI[0].mapname = level CreateString( level.mapvote["map1"].mapname + "\n" + level.mapvote["map1"].gametypeUI, "objective", 1.2, "CENTER", "CENTER", -220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5 );
    mapsUI[1].mapname = level CreateString( level.mapvote["map2"].mapname + "\n" + level.mapvote["map2"].gametypeUI, "objective", 1.2, "CENTER", "CENTER",    0, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5 );
    mapsUI[2].mapname = level CreateString( level.mapvote["map3"].mapname + "\n" + level.mapvote["map3"].gametypeUI, "objective", 1.2, "CENTER", "CENTER",  220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5 );

    if (getDvarInt("mv_extramaps") == 1)
    {
        buttons hud::setPoint("CENTER", "CENTER", 0, 150);

        mapsUI[3] = spawnStruct();
        mapsUI[4] = spawnStruct();

        mapsUI[3].mapname = level CreateString( level.mapvote["map4"].mapname + "\n" + level.mapvote["map4"].gametypeUI, "objective", 1.2, "CENTER", "CENTER", -120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5 );
        mapsUI[4].mapname = level CreateString( level.mapvote["map5"].mapname + "\n" + level.mapvote["map5"].gametypeUI, "objective", 1.2, "CENTER", "CENTER",  120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5 );
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
    }

    wait 1;

    level notify("mv_start_vote");

    mv_sentence = GetDvarString("mv_sentence");
    mv_socialname = GetDvarString("mv_socialname");
    mv_sociallink = GetDvarString("mv_sociallink");

    credits = level hud::createServerFontString("objective", 1.2);
    credits hud::setPoint("BOTTOM_LEFT", "BOTTOM_LEFT", 15, -70);

    credits setText(
        mv_sentence +
        "\n^7Developed by @^5DoktorSAS\n" +
        mv_socialname + ": " + mv_sociallink
    );

    credits affectElement("alpha", 0.5, 1);

    timer = level hud::createServerTimer("objective", 2);
    timer hud::setPoint("TOP", "TOP", 0, 30);
    timer setTimer(level.mapvote["time"]);

    wait level.mapvote["time"];

    // Close the voting state before waking the threads.
    level.isInVote = 0;

    // Destroy the boxes and images of the players.
    level notify("mv_destroy_hud");

    // Wake up VoteManager even if no recent vote has arrived.
    level notify("mv_vote_cast");

    foreach (map in mapsUI)
    {
        map.mapname affectElement("alpha", 0.4, 0);

        if (isDefined(map.textbg))
        {
            map.textbg affectElement("alpha", 0.4, 0);
        }
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

    votes[0].votes = level CreateString( 0, "objective", 1.5, "LEFT", "CENTER", -150, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
    SetVoteColorLabel( votes[0].votes, getDvarInt("mv_votecolor"));
    votes[0].map = level.mapvote["map1"];

    votes[1].votes = level CreateString( 0, "objective", 1.5, "CENTER", "CENTER", 75, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
    SetVoteColorLabel( votes[1].votes, getDvarInt("mv_votecolor"));
    votes[1].map = level.mapvote["map2"];

    votes[2].votes = level CreateString( 0, "objective", 1.5, "RIGHT", "CENTER", 290, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
    SetVoteColorLabel( votes[2].votes, getDvarInt("mv_votecolor"));
    votes[2].map = level.mapvote["map3"];

    if (getDvarInt("mv_extramaps") == 1)
    {
        votes[3] = spawnStruct();
        votes[4] = spawnStruct();

        votes[3].votes = level CreateString( 0, "objective", 1.5, "LEFT", "CENTER", -50, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
        SetVoteColorLabel( votes[3].votes, getDvarInt("mv_votecolor"));
        votes[3].map = level.mapvote["map4"];

        votes[4].votes = level CreateString( 0, "objective", 1.5, "RIGHT", "CENTER", 190, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
        SetVoteColorLabel( votes[4].votes, getDvarInt("mv_votecolor"));
        votes[4].map = level.mapvote["map5"];
    }

    // Initialize and position the counters.
    // This block retrieves the original positioning of the HUD.
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
        vote.votes setValue(0);

        // Place the numbers next to their cards.
        vote.votes.y = 1 + dynamic_position;

        // Make the counters visible with an animation.
        vote.votes.alpha = 0;
        vote.votes.hidden = false;
        vote.votes affectElement("alpha", 1.6, 1);
    }

    // Initialize the shared voting state.
    level.isInVote = 1;

    // Count and update the votes until the time runs out.
    while (level.isInVote)
    {
        level waittill("mv_vote_cast");

        // The voting has ended: exit the loop.
        if (!level.isInVote)
        {
            break;
        }

        // Recalculate the votes based on the latest election
        // confirmed by each player.
        for (i = 0; i < votes.size; i++)
        {
            votes[i].value = 0;
        }

        foreach (player in level.players)
        {
            if (isDefined(player.mv_vote))
            {
                playerVote = player.mv_vote;

                if (playerVote >= 0 && playerVote < votes.size)
                {
                    votes[playerVote].value++;
                }
            }
        }

        // Update the numbers on the screen.
        for (i = 0; i < votes.size; i++)
        {
            votes[i].votes setValue(votes[i].value);
        }
    }

    // Final count: includes the last recorded vote.
    for (i = 0; i < votes.size; i++)
    {
        votes[i].value = 0;
    }

    foreach (player in level.players)
    {
        if (isDefined(player.mv_vote))
        {
            playerVote = player.mv_vote;

            if (playerVote >= 0 && playerVote < votes.size)
            {
                votes[playerVote].value++;
            }
        }
    }

    // Display the final result before removing the HUD.
    for (i = 0; i < votes.size; i++)
    {
        votes[i].votes setValue(votes[i].value);
    }

    // Fade out the vote counters.
    foreach (vote in votes)
    {
        if (isDefined(vote.votes))
        {
            vote.votes affectElement("alpha", 0.5, 0);
        }
    }

    wait 0.55;

    // Destroy the HUD elements for the counters.
    foreach (vote in votes)
    {
        if (isDefined(vote.votes))
        {
            vote.votes hud::destroyElem();
        }
    }

    // Determine the winner and continue the rotation.
    winner = MapvoteGetMostVotedMap(votes);
    map = winner.map;

    MapvoteSetRotation(map.exec_rotation, map.gametype);

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

function PrepareFallbackCfg()
{
    cursor = GetDvarString("sv_maprotationcurrent");
    if (cursor == "")
        cursor = GetDvarString("sv_maprotation");
    tokens = strTok(cursor, " ");
    mode = GetDvarString("g_gametype");
    for (i = 0; i + 1 < tokens.size; i += 2)
    {
        if (tokens[i] == "gametype")
            mode = tokens[i + 1];
        if (tokens[i] == "map")
        {
            PrepareModeCfg(mode);
            return;
        }
    }
}

function PrepareModeCfg(gametype)
{
    cfg = GetModeCfg(gametype);

    if (cfg == "" || isSubStr(cfg, ".."))
        return false;
    for (i = 0; i < cfg.size; i++)
    {
        if (!isSubStr("abcdefghijklmnopqrstuvwxyz0123456789_/.-", tolower(getSubStr(cfg, i, i + 1))))
        {
            return false;
        }
    }
    SetDvar("mv_cfg_queue_done", "0");
    executecommand("exec " + cfg);
    executecommand("set mv_cfg_queue_done 1");

    for (i = 0; i < 60 && GetDvarInt("mv_cfg_queue_done") != 1; i++)
        wait 0.05;
    return true;
}

function MapvoteSetRotation(mapid, gametype)
{
    if (isDefined(level.mv_rotation_queued))
        return;
    level.mv_rotation_queued = true;
    if (isDefined(mapid) && mapid != "" && isDefined(gametype) && gametype != "" && PrepareModeCfg(gametype))
    {
        // BOIII accepts gametype and map here. The CFG is executed separately before ExitLevel.
        rotation = "gametype " + GetModeCode(gametype) + " map " + mapid;
        remaining = GetDvarString("sv_maprotationcurrent");
        if (remaining != "")
            rotation = rotation + " " + remaining;
        SetDvar("sv_maprotationcurrent", rotation);
    }
    else
        PrepareFallbackCfg();
    level notify("mv_ended");

    // We force the immediate loading of the winning level.
    ExitLevel(false);
}

function GetGametypeDisplayName(gametype)
{
    mode = GetModeCode(gametype);
    displayName = GametypeToName(mode);

    if (!isDefined(displayName) || tolower(displayName) == "invalid")
    {
    	// Display the actual identifier so that any mode 
        // that does not yet have a name configured can be recognized.
        return toUpper(mode);
    }

    return displayName;
}

function GetModeCode(gametype)
{
    parts = strTok(gametype, ";");
    if (parts.size > 0)
        return tolower(parts[0]);
    return tolower(gametype);
}

// mv_gametypes accepts a mode or mode;cfg_path for a custom ruleset.
function GetModeCfg(gametype)
{
    parts = strTok(gametype, ";");
    if (parts.size > 1 && parts[1] != "")
        return parts[1];

    mode = GetModeCode(gametype);
    if (mode == "")
        return "";
    return "gamedata/gamesettings/mp/gamesettings_" + mode + ".cfg";
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
    if(getDvarInt("mv_previews") == 1)
    {
        level.maps_data[key].image = image;
    }
}

// Register new maps here and precache each preview material above.
function BuildMapsData()
{
	level.maps_data = [];
	insertMap("mp_biodome", "Aquarium", "img_t7_menu_mp_preview_biodome", "mp_biodome");
	insertMap("mp_spire", "Breach", "img_t7_menu_mp_preview_spire", "mp_spire");
	insertMap("mp_sector", "Combine", "img_t7_menu_mp_preview_sector", "mp_sector");
	insertMap("mp_apartments", "Evac", "img_t7_menu_mp_preview_apartments", "mp_apartments");
	insertMap("mp_chinatown", "Exodus", "img_t7_menu_mp_preview_chinatown", "mp_chinatown");
	insertMap("mp_veiled", "Fringe", "img_t7_menu_mp_preview_veiled", "mp_veiled");
	insertMap("mp_havoc", "Havoc", "img_t7_menu_mp_preview_havoc", "mp_havoc");
	insertMap("mp_ethiopia", "Hunted", "img_t7_menu_mp_preview_ethiopia", "mp_ethiopia");
	insertMap("mp_infection", "Infection", "img_t7_menu_mp_preview_infection", "mp_infection");
	insertMap("mp_metro", "Metro", "img_t7_menu_mp_preview_metro", "mp_metro");
	insertMap("mp_redwood", "Redwood","img_t7_menu_mp_preview_redwood", "mp_redwood");
	insertMap("mp_stronghold", "Stronghold", "img_t7_menu_mp_preview_stronghold", "mp_stronghold");
	insertMap("mp_nuketown_x", "Nuk3town", "img_t7_menu_mp_preview_nuketown_x", "mp_nuketown_x");

	// Awakening DLC
	insertMap("mp_crucible", "Gauntlet", "img_t7_menu_mp_preview_crucible", "mp_crucible");
	insertMap("mp_rise", "Rise", "img_t7_menu_mp_preview_rise", "mp_rise");
	insertMap("mp_skyjacked", "Skyjacked", "img_t7_menu_mp_preview_skyjacked", "mp_skyjacked");
	insertMap("mp_waterpark", "Splash", "img_t7_menu_mp_preview_waterpark", "mp_waterpark");

	// Eclipse DLC
	insertMap("mp_kung_fu", "Knockout", "img_t7_menu_mp_preview_kung_fu", "mp_kung_fu");
	insertMap("mp_conduit", "Rift", "img_t7_menu_mp_preview_conduit", "mp_conduit");
	insertMap("mp_aerospace", "Spire", "img_t7_menu_mp_preview_aerospace", "mp_aerospace");
	insertMap("mp_banzai", "Verge", "img_t7_menu_mp_preview_banzai", "mp_banzai");

	// Descent DLC
	insertMap("mp_shrine", "Berserk", "img_t7_menu_mp_preview_shrine", "mp_shrine");
	insertMap("mp_cryogen", "Cryogen", "img_t7_menu_mp_preview_cryogen", "mp_cryogen");
	insertMap("mp_rome", "Empire", "img_t7_menu_mp_preview_rome", "mp_rome");
	insertMap("mp_arena", "Rumble", "img_t7_menu_mp_preview_arena", "mp_arena");

	// Salvation DLC
	insertMap("mp_ruins", "Citadel", "img_t7_menu_mp_preview_ruins", "mp_ruins");
	insertMap("mp_miniature", "Micro", "img_t7_menu_mp_preview_miniature", "mp_miniature");
	insertMap("mp_western", "Outlaw", "img_t7_menu_mp_preview_western", "mp_western");
	insertMap("mp_city", "Rupture", "img_t7_menu_mp_preview_city", "mp_city");

	// Bonus Maps
	insertMap("mp_veiled_heyday", "Fringe Night", "img_t7_menu_mp_preview_veiled_heyday", "mp_veiled_heyday");
	insertMap("mp_redwood_ice", "Redwood Snow", "img_t7_menu_mp_preview_redwood_ice", "mp_redwood_ice");

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
			insertMap("mp_minecraft", "Minecraft", "preview_mp_minecraft", "mp_minecraft");
	*/
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
    hud.archived = 0;
    hud.hideWhenInMenu = 0;

    return hud;
}

function DrawShader(shader, x, y, width, height, color, alpha, sort, align, relative, isLevel)
{
    if (isDefined(isLevel))
        hud = NewHudElem();
    else
        hud = NewClientHudElem(self);

    hud.elemType = "icon";
    hud.x = x;
    hud.y = y;
    hud.width = width;
    hud.height = height;
    hud.xOffset = 0;
    hud.yOffset = 0;

    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
    hud.foreground = true;

    hud hud::setParent(level.uiParent);

    if (isDefined(align) && isDefined(relative))
        hud hud::setPoint(align, relative, x, y);

    hud.hidden = false;
    hud.archived = false;
    hud.hideWhenInMenu = true;

    hud SetShader(shader, width, height);

    return hud;
}

function CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
	uiElement = newClientHudElem(self);
	uiElement.elemType = "icon";
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
    if (!isDefined(color))
        return (1, 1, 1);
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
		return (0.152, 0.329, 0.929);

	case "lighgreen": // Compatibility with the old server.cfg typo.
	case "lightgreen":
	case "light green":
		return (0.09, 1, 0.09);

	case "orange":
		return (1, 0.662, 0.035);

	case "yellow":
		return (0.968, 0.992, 0.043);

	case "brown":
		return (0.501, 0.250, 0);

	case "cyan":
		return (0, 1, 1);

    case "white":
        return (1, 1, 1);
    }
    return (1, 1, 1);
}

function SetVoteColorLabel(hud, colorIndex)
{
    switch (colorIndex)
    {
        case 0:
            hud.label = &"^0";
            break;

        case 1:
            hud.label = &"^1";
            break;

        case 2:
            hud.label = &"^2";
            break;

        case 3:
            hud.label = &"^3";
            break;

        case 4:
            hud.label = &"^4";
            break;

        case 5:
            hud.label = &"^5";
            break;

        case 6:
            hud.label = &"^6";
            break;

        case 7:
            hud.label = &"^7";
            break;

        case 8:
            hud.label = &"^8";
            break;

        case 9:
            hud.label = &"^9";
            break;

        default:
            hud.label = &"^7";
            break;
    }
}

function affectElement(type, time, value)
{
    if (!isDefined(self) || !isDefined(value))
        return;
    if (type == "x" || type == "y")
    {
        self moveOverTime(time);
    }
    else
    {
        self fadeOverTime(time);
    }
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
	case "dm":
		return "Free for all";
	break;
	case "tdm":
		return "Team Deathmatch";
	break;
	case "ball":
		return "Uplink";
	break;
	case "sd":
		return "Search & Destroy";
	break;
	case "sr":
		return "Search & Rescue";
	break;
	case "dom":
		return "Domination";
	break;
	case "dem":
		return "Demolition";
	break;
	case "conf":
		return "Kill Confirmed";
	break;
	case "ctf":
		return "Capture the Flag";
	break;
	case "shrp":
		return "Sharpshooter";
	break;
	case "gun":
		return "Gun Game";
	break;
	case "sas":
		return "Sticks & Stones";
	break;
	case "hq":
		return "Headquaters";
	break;
	case "koth":
		return "Hardpoint";
	break;
	case "escort":
		return "Safeguard";
	break;
	case "clean":
		return "Fracture";
	break;
	case "prop":
		return "Prop Hunt";
	break;
	case "infect":
		return "Infected";
	break;
	case "sniperonly":
		return "Snipers Only";
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

function GetRealPlayers()
{
    numplayers = 0;
    foreach (player in level.players)
	{
		if (!player util::is_bot())
            numplayers++;
	}

    return numplayers;
}
