/// @description Inicializa las propiedades comunes de los recogibles

//Evitar entregar una recompensa más de una vez
Collected = false;

//Permitir recogida mediante enemigos lanzados
CanCollectByThrown = false;

//Cada hijo define su recompensa
ApplyReward = function(Game, Player)
{
    return false;
};

//Validar y procesar una recogida
TryCollect = function(Player, ByThrown)
{
    if (Collected)
    {
        return false;
    }

    if (!instance_exists(Player))
    {
        return false;
    }

    if (Player.ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        return false;
    }

    if (ByThrown && !CanCollectByThrown)
    {
        return false;
    }

    var Game = instance_find(objGame, 0);

    if (!instance_exists(Game))
    {
        return false;
    }

    //Bloquear cualquier segundo intento
    Collected = true;

    if (!ApplyReward(Game, Player))
    {
        Collected = false;
        return false;
    }

    instance_destroy();

    return true;
};