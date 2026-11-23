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

    enum PLAYER_ANIMATION_STATE
    {
        IDLE,
        WALK,
        RUN,
        JUMP,
        FALL,
        SKID,
        HAMMER
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
    
    enum PORCUPINE_BLOCK_PHASE
    {
        ENTER,
        HOLD,
        EXIT
    }
    
    enum DRAGON_FIRE_PHASE
    {
        WAIT,
        PREPARE,
        SPIT
    }
    
    enum BAT_PHASE
    {
        WAIT,
        DROP,
        FLY
    }

    enum THROW_MODE
    {
        HORIZONTAL,
        ARC
    }
    
    enum BLOCK_STATE
    {
        READY,
        ACTIVE,
        EMPTY
    }
    
    enum BLOCK_HIT
    {
        BELOW,
        HAMMER,
        THROWN
    }
}