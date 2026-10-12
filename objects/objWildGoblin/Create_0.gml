/// @description Inicializa el comportamiento del duende salvaje

//Inicializar propiedades heredadas
event_inherited();

//Propiedades del duende
ContactDamage = 1;
MoveSpeed = 0.50;

UsesGravity = true;
Gravity = 0.16;
MaxFallSpeed = 5.90;

Facing = -1;

//Avanzar constantemente
UpdateNormalState = function()
{
    HSpeed = MoveSpeed * Facing;
};

//Girar al tocar una pared
OnWallHit = function()
{
    Facing *= -1;
    HSpeed = 0;
};

//Girar si dañó al jugador desde atrás
OnPlayerDamaged = function(Player, PlayerSide)
{
    var HitFromBehind =
        PlayerSide == -Facing;

    if (HitFromBehind)
    {
        Facing = PlayerSide;

        HSpeed =
            MoveSpeed
            * Facing;

        image_xscale = Facing;
    }
};