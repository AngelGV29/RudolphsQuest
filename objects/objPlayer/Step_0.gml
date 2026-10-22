/// @description Procesa entradas, movimiento y colisiones

//1. Comprobar entradas

//Caminar
var LeftHeld = keyboard_check(vk_left);
var RightHeld = keyboard_check(vk_right);

//Correr
var RunHeld = keyboard_check(vk_control);

//Saltar
var JumpHeld = keyboard_check(ord("Z"));
var JumpPressed = keyboard_check_pressed(ord("Z"));
var JumpReleased = keyboard_check_released(ord("Z"));

//Ataque con el martillo
var HammerPressed =
    keyboard_check_pressed(ord("X"));

//Cálculos de dirección
var MoveInput = RightHeld - LeftHeld;
var InputMaxSpeed;

//Actualizar invulnerabilidad
if (InvulnerabilityTimer > 0)
{
    InvulnerabilityTimer -= 1;
}

//Actualizar estado de daño
if (ActionState == PLAYER_ACTION_STATE.HURT)
{
    HurtTimer -= 1;

    if (HurtTimer <= 0)
    {
        HurtTimer = 0;

        ActionState =
            PLAYER_ACTION_STATE.NORMAL;
    }
}

//Actualizar muerte
if (ActionState == PLAYER_ACTION_STATE.DEAD)
{
    DeathTimer -= 1;

    if (DeathTimer <= 0)
    {
        room_restart();
        exit;
    }
}

//Determinar si el jugador puede controlar a Rudolph
var CanControl =
    ActionState != PLAYER_ACTION_STATE.HURT
    && ActionState != PLAYER_ACTION_STATE.DEAD;

if (!CanControl)
{
    MoveInput = 0;

    RunHeld = false;

    JumpHeld = false;
    JumpPressed = false;
    JumpReleased = false;
    
    HammerPressed = false;
}

//Iniciar el martillazo
if (
    CanControl
    && HammerPressed
    && ActionState == PLAYER_ACTION_STATE.NORMAL
)
{
    StartHammerAttack();
}

//Actualizar el martillazo
UpdateHammerAttack();

//Calcular el límite de velocidad en el aire
if (RunHeld)
{
    InputMaxSpeed = MaxRunSpeed;
}
else
{
    InputMaxSpeed = MaxWalkSpeed;
}

//2. Comprobar el suelo

var WasOnGround = OnGround;

OnGround = place_meeting(x, y + 1, objSolid);

//Guardar límite al salir de una plataforma
if (WasOnGround && !OnGround)
{
    AirMaxSpeed = max(
        abs(HSpeed),
        InputMaxSpeed
    );
}


//3. Actualizar coyote time

if (OnGround)
{
    CoyoteTimer = CoyoteFrames;
}
else
{
    CoyoteTimer = max(CoyoteTimer - 1, 0);
}


//4. Actualizar buffer de salto

if (JumpPressed)
{
    JumpBufferTimer = JumpBufferFrames;
}
else
{
    JumpBufferTimer = max(JumpBufferTimer - 1, 0);
}


//5. Calcular movimiento horizontal

var MaxSpeed;

if (OnGround)
{
    MaxSpeed = InputMaxSpeed;
}
else
{
    MaxSpeed = AirMaxSpeed;
}

var TargetSpeed = MoveInput * MaxSpeed;
//Calcular aceleración horizontal
var CurrentAccel;

if (MoveInput != 0)
{
    var IsTurning =
        HSpeed != 0
        && sign(HSpeed) != sign(MoveInput);

    if (OnGround)
    {
        if (IsTurning)
        {
            CurrentAccel = GroundTurnAccel;
        }
        else
        {
            CurrentAccel = GroundAccel;
        }
    }
    else
    {
        if (IsTurning)
        {
            CurrentAccel = AirTurnAccel;
        }
        else
        {
            CurrentAccel = AirAccel;
        }
    }
}
else
{
    if (OnGround)
    {
        CurrentAccel = GroundDecel;
    }
    else
    {
        CurrentAccel = AirDecel;
    }
}

HSpeed += clamp(
    TargetSpeed - HSpeed,
    -CurrentAccel,
    CurrentAccel
);

if (MoveInput != 0)
{
    Facing = sign(MoveInput);
}


//6. Iniciar salto

//Iniciar salto
if (JumpBufferTimer > 0 && CoyoteTimer > 0)
{
    if (OnGround)
    {
        AirMaxSpeed = max(
            abs(HSpeed),
            InputMaxSpeed
        );
    }
    else
    {
        AirMaxSpeed = max(
            AirMaxSpeed,
            abs(HSpeed)
        );
    }

    VSpeed = -JumpSpeed;
    VSubPixel = 0;

    OnGround = false;

    CoyoteTimer = 0;
    JumpBufferTimer = 0;

    if (!JumpHeld)
    {
        VSpeed *= JumpCutMultiplier;
    }
}


//7. Interrumpir salto al soltar Z

if (JumpReleased && VSpeed < 0)
{
    VSpeed *= JumpCutMultiplier;
}


//8. Aplicar gravedad

if (!OnGround)
{
    VSpeed = min(
        VSpeed + Gravity,
        MaxFallSpeed
    );
}
else if (VSpeed > 0)
{
    VSpeed = 0;
}


//9. Convertir velocidad horizontal a píxeles

HSubPixel += HSpeed;

var MoveX =
    floor(abs(HSubPixel))
    * sign(HSubPixel);

HSubPixel -= MoveX;


//10. Resolver movimiento horizontal

if (MoveX != 0)
{
    var StepX = sign(MoveX);

    repeat (abs(MoveX))
    {
        if (!place_meeting(x + StepX, y, objSolid))
        {
            x += StepX;
        }
        else
        {
            HSpeed = 0;
            HSubPixel = 0;
            break;
        }
    }
}


//11. Convertir velocidad vertical a píxeles

VSubPixel += VSpeed;

var MoveY =
    floor(abs(VSubPixel))
    * sign(VSubPixel);

VSubPixel -= MoveY;


//12. Resolver movimiento vertical

if (MoveY != 0)
{
    var StepY = sign(MoveY);

    repeat (abs(MoveY))
    {
        if (!place_meeting(x, y + StepY, objSolid))
        {
            y += StepY;
        }
        else
        {
            VSpeed = 0;
            VSubPixel = 0;
            break;
        }
    }
}


//13. Actualizar contacto con el suelo

OnGround = place_meeting(x, y + 1, objSolid);


//14. Determinar estado de animación
var NewAnimationState;

var IsMoving = abs(HSpeed) > 0.05;

var IsSkidding =
    OnGround
    && MoveInput != 0
    && HSpeed != 0
    && sign(HSpeed) != sign(MoveInput);

if (ActionState == PLAYER_ACTION_STATE.HAMMER)
{
    NewAnimationState =
        PLAYER_ANIMATION_STATE.HAMMER;
}
else if (!OnGround)
{
    if (VSpeed < 0)
    {
        NewAnimationState =
            PLAYER_ANIMATION_STATE.JUMP;
    }
    else
    {
        NewAnimationState =
            PLAYER_ANIMATION_STATE.FALL;
    }
}
else if (IsSkidding)
{
    NewAnimationState =
        PLAYER_ANIMATION_STATE.SKID;
}
else if (!IsMoving)
{
    NewAnimationState =
        PLAYER_ANIMATION_STATE.IDLE;
}
else if (abs(HSpeed) > MaxWalkSpeed)
{
    NewAnimationState =
        PLAYER_ANIMATION_STATE.RUN;
}
else
{
    NewAnimationState =
        PLAYER_ANIMATION_STATE.WALK;
}


//15. Cambiar animación

if (AnimationState != NewAnimationState)
{
    AnimationState = NewAnimationState;

    switch (AnimationState)
    {
        case PLAYER_ANIMATION_STATE.IDLE:
            sprite_index = sprPlayerIdlePlaceholder;
            break;

        case PLAYER_ANIMATION_STATE.WALK:
            sprite_index = sprPlayerWalkPlaceholder;
            break;

        case PLAYER_ANIMATION_STATE.RUN:
            sprite_index = sprPlayerRunPlaceholder;
            break;

        case PLAYER_ANIMATION_STATE.JUMP:
            sprite_index = sprPlayerJumpPlaceholder;
            break;

        case PLAYER_ANIMATION_STATE.FALL:
            sprite_index = sprPlayerFallPlaceholder;
            break;

        case PLAYER_ANIMATION_STATE.SKID:
            sprite_index = sprPlayerSkidPlaceholder;
            break;
        case PLAYER_ANIMATION_STATE.HAMMER:
            sprite_index = sprPlayerHammerPlaceholder;
            break;
    }

    image_index = 0;
    image_speed = 0;
}

//Mostrar la invulnerabilidad
if (InvulnerabilityTimer > 0)
{
    if ((InvulnerabilityTimer div 4) mod 2 == 0)
    {
        image_alpha = 0.35;
    }
    else
    {
        image_alpha = 1;
    }
}
else
{
    image_alpha = 1;
}


//16. Orientar sprite

image_xscale = Facing;