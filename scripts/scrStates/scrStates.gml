function scrStates(){
enum PLAYER_ACTION_STATE
{
    NORMAL,
    HAMMER,
    THROWING,
    SPIN_JUMP,
    DASH,
    HURT,
    DEAD
}

enum ENEMY_STATE
{
    NORMAL,
    FLATTENED,
    CARRIED,
    THROWN,
    WAKING,
    DEFEATED
}

enum THROW_MODE
{
    HORIZONTAL,
    ARC
}
}