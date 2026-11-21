/// @description Cancela el ataque durante estados no normales

if (EnemyState != ENEMY_STATE.NORMAL)
{
    ResetFireAttack();
}

event_inherited();

//Cubrir también cambios de estado ocurridos durante el Step heredado
if (EnemyState != ENEMY_STATE.NORMAL)
{
    ResetFireAttack();
}
