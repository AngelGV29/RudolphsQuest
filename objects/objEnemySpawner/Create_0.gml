/// @description Inicializa un punto generador de enemigos

//Tipo de enemigo que debe crear
EnemyObject = noone;

//Referencia al enemigo actualmente creado
ActiveEnemy = noone;

//Estado permanente durante la habitación
Defeated = false;
SpawnReady = true;

//Posición original del enemigo
SpawnX = x;
SpawnY = y;

//Área en la que aparece
ActivateRangeX = 256;
ActivateRangeY = 144;

//Distancia necesaria para permitir otro respawn
ResetRangeX = 384;
ResetRangeY = 240;

//Área máxima de actividad
DespawnRangeX = 480;
DespawnRangeY = 320;

//Margen inferior de la habitación
FallMargin = 64;

//No mostrar el generador durante el juego
visible = false;

//Crea el enemigo en su posición original
SpawnEnemy = function(Player)
{
    if (EnemyObject == noone)
    {
        return;
    }

    var NewEnemy = instance_create_layer(
        SpawnX,
        SpawnY,
        layer,
        EnemyObject
    );

    NewEnemy.SpawnOwner = id;

    var SpawnFacing = sign(Player.x - SpawnX);

    if (SpawnFacing == 0)
    {
        SpawnFacing = -1;
    }

    NewEnemy.Facing = SpawnFacing;
    NewEnemy.image_xscale = SpawnFacing;

    ActiveEnemy = NewEnemy;
    SpawnReady = false;
};

//Retira temporalmente al enemigo
DespawnEnemy = function()
{
    if (!instance_exists(ActiveEnemy))
    {
        ActiveEnemy = noone;
        SpawnReady = false;
        return;
    }

    var Enemy = ActiveEnemy;

    ActiveEnemy = noone;
    SpawnReady = false;

    Enemy.RemoveFromLevel(false);
};