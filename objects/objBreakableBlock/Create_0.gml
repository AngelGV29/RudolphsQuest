/// @description Inicializa un bloque rompible

event_inherited();

Breaking = false;

//Romper una sola vez
ActivateBlock = function(Attacker, HitType)
{
    if (Breaking)
    {
        return false;
    }

    Breaking = true;

    BumpEnemies();

    instance_destroy();

    return true;
};