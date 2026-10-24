#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;

#namespace mv_material_precache;

// Materiales básicos y material de prueba
#precache("statusicon", "uie_t7_hud_waypoints_compassping_enemy");
#precache("statusicon", "compassping_friendlyyelling_mp");

// Multijugador: mapas originales
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

// Awakening
#precache("material", "img_t7_menu_mp_preview_crucible");
#precache("material", "img_t7_menu_mp_preview_rise");
#precache("material", "img_t7_menu_mp_preview_skyjacked");
#precache("material", "img_t7_menu_mp_preview_waterpark");

// Eclipse
#precache("material", "img_t7_menu_mp_preview_kung_fu");
#precache("material", "img_t7_menu_mp_preview_conduit");
#precache("material", "img_t7_menu_mp_preview_aerospace");
#precache("material", "img_t7_menu_mp_preview_banzai");

// Descent
#precache("material", "img_t7_menu_mp_preview_shrine");
#precache("material", "img_t7_menu_mp_preview_cryogen");
#precache("material", "img_t7_menu_mp_preview_rome");
#precache("material", "img_t7_menu_mp_preview_arena");

// Salvation
#precache("material", "img_t7_menu_mp_preview_ruins");
#precache("material", "img_t7_menu_mp_preview_miniature");
#precache("material", "img_t7_menu_mp_preview_western");
#precache("material", "img_t7_menu_mp_preview_city");

// Mapas adicionales
#precache("material", "img_t7_menu_mp_preview_veiled_heyday");
#precache("material", "img_t7_menu_mp_preview_redwood_ice");

REGISTER_SYSTEM("mv_material_precache", &__init__, undefined)

function __init__()
{
}