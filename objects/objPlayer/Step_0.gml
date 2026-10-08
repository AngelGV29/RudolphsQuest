/// @description Procesa entradas, movimiento y colisiones

//Comprobar entradas
var LeftHeld =
    keyboard_check(vk_left);

var RightHeld =
    keyboard_check(vk_right);

var RunHeld = keyboard_check(vk_control);
var JumpPressed = keyboard_check_pressed(ord("Z"));

var MoveInput = RightHeld - LeftHeld;


//Comprobar el suelo
OnGround = place_meeting(x, y + 1, objSolid);


//Calcular movimiento horizontal
var MaxSpeed;

if (RunHeld)
{
    MaxSpeed = MaxRunSpeed;
}
else
{
    MaxSpeed = MaxWalkSpeed;
}

var TargetSpeed = MoveInput * MaxSpeed;
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
        CurrentAccel = AirAccel;
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


//Salto y gravedad
if (JumpPressed && OnGround)
{
    VSpeed = -JumpSpeed;
    OnGround = false;
}

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



//Convertir velocidad horizontal a píxeles
HSubPixel += HSpeed;

var MoveX =
    floor(abs(HSubPixel))
    * sign(HSubPixel);

HSubPixel -= MoveX;


//Resolver movimiento horizontal
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


//Convertir velocidad vertical a píxeles
VSubPixel += VSpeed;

var MoveY =
    floor(abs(VSubPixel))
    * sign(VSubPixel);

VSubPixel -= MoveY;


//Resolver movimiento vertical
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


//Actualizar contacto con el suelo
OnGround = place_meeting(x, y + 1, objSolid);