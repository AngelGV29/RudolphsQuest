/// @description Inicializa el movimiento básico del jugador
//Límites de velocidad horizontal
MaxWalkSpeed = 1.75;
MaxRunSpeed = 3.50;

//Límite horizontal conservado durante el salto
AirMaxSpeed = MaxWalkSpeed;

//Aceleración, frenado y giro en el suelo
GroundAccel = 0.05;
GroundDecel = 0.2;
GroundTurnAccel = 0.2;

//Aceleración,frenado y gito en el aire
AirAccel = 0.05;
AirDecel = 0.01;
AirTurnAccel = 0.15;

//Impulso de salto, gravedad y límite de caida
JumpSpeed = 5.75;
Gravity = 0.16;
MaxFallSpeed = 5.9;

//Velocidad horizontal y vertical actuales
HSpeed = 0;
VSpeed = 0;

//Fracciones de movimiento pendientes de aplicar
HSubPixel = 0;
VSubPixel = 0;

Facing = 1; //Indica hacia donde está mirando el jugador: -1 izquierda y 1 derecha
OnGround = false; //Indica si el jugador está en el suelo

//Duración y contador del coyote tume
CoyoteFrames = 6;
CoyoteTimer = 0;

//Duración y contador del buffer de salto
JumpBufferFrames = 6;
JumpBufferTimer = 0;

//Proporción de impulso conservado al interrumpir el salto
JumpCutMultiplier = 0.4;

//Vida
MaxHp = 4;
Hp = MaxHp;

//Duración del daño
HurtFrames = 18;
HurtTimer = 0;

//Invulnerabilidad después de recibir daño
InvulnerabilityFrames = 90;
InvulnerabilityTimer = 0;

//Retroceso
KnockbackHSpeed = 2;
KnockbackVSpeed = 1.5;

//Muerte
DeathFrames = 45;
DeathTimer = 0;

//Estados lógicos y visual del jugador
ActionState = PLAYER_ACTION_STATE.NORMAL;
AnimationState = PLAYER_ANIMATION_STATE.IDLE;

//Aplica daño y devuelve si el golpe fue aceptado
TakeDamage = function(DamageAmount, SourceX)
{
    if (ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        return false;
    }

    if (InvulnerabilityTimer > 0)
    {
        return false;
    }

    Hp = max(
        Hp - DamageAmount,
        0
    );

    var KnockbackDirection = sign(
        x - SourceX
    );

    if (KnockbackDirection == 0)
    {
        KnockbackDirection = -Facing;
    }

    HSpeed =
        KnockbackHSpeed
        * KnockbackDirection;

    VSpeed = -KnockbackVSpeed;

    HSubPixel = 0;
    VSubPixel = 0;

    AirMaxSpeed = max(
        AirMaxSpeed,
        abs(HSpeed)
    );

    OnGround = false;
    CoyoteTimer = 0;
    JumpBufferTimer = 0;

    if (Hp <= 0)
    {
        ActionState =
            PLAYER_ACTION_STATE.DEAD;

        DeathTimer = DeathFrames;
    }
    else
    {
        ActionState =
            PLAYER_ACTION_STATE.HURT;

        HurtTimer = HurtFrames;

        InvulnerabilityTimer =
            InvulnerabilityFrames;
    }

    return true;
};