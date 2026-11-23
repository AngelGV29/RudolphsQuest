/// @description Inicializa las reglas del intento actual

if (instance_number(objLevelController) > 1)
{
    instance_destroy();
    exit;
}

//Respaldos para propiedades del editor
if (!variable_instance_exists(id, "TimeLimitSeconds"))
{
    TimeLimitSeconds = 300;
}

if (!variable_instance_exists(id, "TimerEnabled"))
{
    TimerEnabled = true;
}

if (!variable_instance_exists(id, "VoidDeathEnabled"))
{
    VoidDeathEnabled = true;
}

if (!variable_instance_exists(id, "VoidMargin"))
{
    VoidMargin = 40;
}

//Temporizador en segundos enteros
TimeSeconds = max(
    0,
    floor(TimeLimitSeconds)
);

TimerSteps = 0;
TimerRunning = TimerEnabled;

//Resultado del nivel
LevelCompleted = false;

TimeBonusPerSecond = 25;
TimeBonusSeconds = 0;
TimeBonusPoints = 0;

//Comprobar únicamente el límite inferior de la cámara
CheckVoid = function(Camera)
{
    if (
        !VoidDeathEnabled
        || LevelCompleted
        || Camera == -1
    )
    {
        return;
    }

    var Player = instance_find(objPlayer, 0);

    if (!instance_exists(Player))
    {
        return;
    }

    if (Player.ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        TimerRunning = false;
        return;
    }

    var CameraBottom =
        camera_get_view_y(Camera)
        + camera_get_view_height(Camera);

    //Debe quedar completamente por debajo del límite
    if (
        Player.bbox_top
        > CameraBottom + max(0, VoidMargin)
    )
    {
        Player.DepleteHp();

        TimerRunning = false;
    }
};

//Registrar una victoria y conceder su bonificación una sola vez
CompleteLevel = function()
{
    if (LevelCompleted)
    {
        return false;
    }

    var Player = instance_find(objPlayer, 0);

    if (!instance_exists(Player))
    {
        return false;
    }

    if (
        Player.Hp <= 0
        || Player.ActionState == PLAYER_ACTION_STATE.DEAD
    )
    {
        return false;
    }

    if (TimerEnabled && TimeSeconds <= 0)
    {
        return false;
    }

    var Game = instance_find(objGame, 0);

    if (!instance_exists(Game))
    {
        return false;
    }

    LevelCompleted = true;
    TimerRunning = false;

    TimeBonusSeconds = 0;

    if (TimerEnabled)
    {
        TimeBonusSeconds = TimeSeconds;
    }

    TimeBonusPoints =
        TimeBonusSeconds
        * TimeBonusPerSecond;

    Game.AddScore(TimeBonusPoints);

    return true;
};