#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;

#namespace mv_material_precache;

// Base Map
#precache("material", "img_t7_menu_zm_preview_zod");

// Bonus Map
#precache("material", "img_t7_menu_zm_preview_factory");

// Awakening DLC
#precache("material", "img_t7_menu_zm_preview_castle");

// Eclipse DLC
#precache("material", "img_t7_menu_zm_preview_island");

// Descent DLC
#precache("material", "img_t7_menu_zm_preview_stalingrad");

// Salvation DLC
#precache("material", "img_t7_menu_zm_preview_genesis");

// Zombies Chronicles
#precache("material", "img_t7_menu_zm_preview_cosmodrome");
#precache("material", "img_t7_menu_zm_preview_theater");
#precache("material", "img_t7_menu_zm_preview_moon");
#precache("material", "img_t7_menu_zm_preview_prototype");
#precache("material", "img_t7_menu_zm_preview_tomb");
#precache("material", "img_t7_menu_zm_preview_temple");
#precache("material", "img_t7_menu_zm_preview_asylum");


REGISTER_SYSTEM("mv_material_precache", &__init__, undefined)

function __init__()
{
}