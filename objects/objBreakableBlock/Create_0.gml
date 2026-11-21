/// @description Inicializa un bloque rompible

event_inherited();

Breaking = false;

//Crear las cuatro piezas visuales
SpawnFragments = function()
{
    var CenterX = (bbox_left + bbox_right + 1) * 0.5;
    var CenterY = (bbox_top + bbox_bottom + 1) * 0.5;

    for (var Index = 0; Index < 4; Index += 1)
    {
        var RightSide = (Index mod 2) == 1;
        var BottomSide = Index >= 2;

        var DirX = -1;
        var OffsetY = -4;
        var LaunchVSpeed = -3.5;

        if (RightSide)
        {
            DirX = 1;
        }

        if (BottomSide)
        {
            OffsetY = 4;
            LaunchVSpeed = -2.5;
        }

        var Fragment = instance_create_layer(
            CenterX + 4 * DirX,
            CenterY + OffsetY,
            "Effects",
            objBlockFragment
        );

        Fragment.image_index = Index;

        Fragment.HSpeed = 1.25 * DirX;
        Fragment.VSpeed = LaunchVSpeed;
    }
};

//Romper una sola vez
ActivateBlock = function(Attacker, HitType)
{
    if (Breaking)
    {
        return false;
    }

    Breaking = true;

    BumpEnemies();
    BumpPickups();

    SpawnFragments();

    audio_play_sound(sndBlockBreak, 1, false);

    instance_destroy();

    return true;
};