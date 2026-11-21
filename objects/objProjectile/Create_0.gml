/// @description Inicializa un proyectil independiente de los enemigos

ProjectileOwner = noone;

Damage = 1;

Facing = 1;

HSpeed = 0;
VSpeed = 0;

HSubPixel = 0;
VSubPixel = 0;

//Valores de seguridad para su eliminación
LifeFrames = 180;
LifeTimer = 0;

DespawnRangeX = 640;
DespawnRangeY = 384;

RoomMargin = 64;

//Efecto opcional al impactar
ImpactSprite = -1;
ImpactFrames = 12;

//Evitar resolver el mismo impacto más de una vez
ImpactResolved = false;

//Procesar impactos desde la posición actual
CheckImpact = function()
{
    if (CheckSolid(x, y))
    {
        return true;
    }

    var Player = instance_place(
        x,
        y,
        objPlayer
    );

    if (Player == noone)
    {
        return false;
    }

    if (Player.ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        return false;
    }

    var SourceX = (bbox_left + bbox_right) * 0.5;

    var DamageApplied = Player.TakeDamage(
        Damage,
        SourceX
    );

    if (DamageApplied)
    {
        audio_play_sound(
            sndDamagePlayer,
            1,
            false
        );
    }

    //El contacto consume el proyectil aunque haya invulnerabilidad
    return true;
};

//Crear el efecto y retirar el proyectil
ResolveImpact = function()
{
    if (ImpactResolved)
    {
        return;
    }

    ImpactResolved = true;

    if (ImpactSprite != -1)
    {
        var Effect = instance_create_layer(
            x,
            y,
            "Effects",
            objProjectileImpactEffect
        );

        Effect.sprite_index = ImpactSprite;

        Effect.DurationFrames = max(
            1,
            floor(ImpactFrames)
        );

        Effect.image_index = 0;

        Effect.image_xscale = Facing;
        Effect.image_yscale = image_yscale;
        Effect.image_angle = image_angle;
    }

    instance_destroy();
};