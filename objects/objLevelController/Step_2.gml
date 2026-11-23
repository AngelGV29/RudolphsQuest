/// @description Actualiza el tiempo mientras el jugador sigue vivo

var Player = instance_find(objPlayer, 0);

if (!instance_exists(Player))
{
    exit;
}

//Congelar definitivamente el reloj durante la muerte
if (
    Player.Hp <= 0
    || Player.ActionState == PLAYER_ACTION_STATE.DEAD
)
{
    TimerRunning = false;
    exit;
}

if (
    !TimerEnabled
    || !TimerRunning
    || LevelCompleted
)
{
    exit;
}

//Un nivel configurado con cero segundos expira inmediatamente
if (TimeSeconds <= 0)
{
    TimeSeconds = 0;
    TimerRunning = false;

    Player.DepleteHp();
    exit;
}

//Convertir pasos de juego a segundos
TimerSteps += 1;

var StepsPerSecond = max(
    1,
    game_get_speed(gamespeed_fps)
);

if (TimerSteps >= StepsPerSecond)
{
    var ElapsedSeconds = floor(
        TimerSteps / StepsPerSecond
    );

    TimerSteps -=
        ElapsedSeconds * StepsPerSecond;

    TimeSeconds = max(
        0,
        TimeSeconds - ElapsedSeconds
    );
}

if (TimeSeconds == 0)
{
    TimerRunning = false;

    Player.DepleteHp();
}