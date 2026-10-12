/// @description Controla la aparición y desaparición del enemigo

var Player = instance_find(objPlayer, 0);

if (Player == noone)
{
    exit;
}

if (Defeated)
{
    exit;
}

//Distancia del jugador al punto original
var PlayerSpawnDistanceX = abs(Player.x - SpawnX);
var PlayerSpawnDistanceY = abs(Player.y - SpawnY);

//Controlar un generador sin enemigo activo
if (!instance_exists(ActiveEnemy))
{
    ActiveEnemy = noone;

    //Esperar a que el jugador se aleje antes de permitir otro respawn
    if (!SpawnReady)
    {
        var OutsideResetArea =
            PlayerSpawnDistanceX > ResetRangeX
            || PlayerSpawnDistanceY > ResetRangeY;

        if (OutsideResetArea)
        {
            SpawnReady = true;
        }
    }

    //Crear al enemigo cuando el jugador regrese
    if (SpawnReady)
    {
        var InsideActivateArea =
            PlayerSpawnDistanceX <= ActivateRangeX
            && PlayerSpawnDistanceY <= ActivateRangeY;

        if (InsideActivateArea)
        {
            SpawnEnemy(Player);
        }
    }

    exit;
}

//Calcular la distancia entre jugador y enemigo
var EnemyDistanceX = abs(Player.x - ActiveEnemy.x);
var EnemyDistanceY = abs(Player.y - ActiveEnemy.y);

var OutsideDespawnArea =
    EnemyDistanceX > DespawnRangeX
    || EnemyDistanceY > DespawnRangeY;

var FellOutsideRoom =
    ActiveEnemy.y > room_height + FallMargin;

//Retirar al enemigo temporalmente
if (OutsideDespawnArea || FellOutsideRoom)
{
    DespawnEnemy();
}