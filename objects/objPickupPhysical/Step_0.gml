/// @description Actualiza duración, movimiento y terreno

//Actualizar duración y advertencia
if (HasLifetime)
{
    LifeTimer += 1;

    if (LifeTimer >= LifeFrames)
    {
        instance_destroy();
        exit;
    }

    var RemainingFrames = LifeFrames - LifeTimer;

    if (RemainingFrames <= BlinkFrames)
    {
        image_alpha =
            ((LifeTimer div BlinkInterval) mod 2 == 0)
            ? 1
            : 0.25;
    }
    else
    {
        image_alpha = 1;
    }
}

//Comprobar apoyo
OnGround = CheckGround();

//Frenar sobre el suelo
if (OnGround)
{
    HSpeed += clamp(
        -HSpeed,
        -GroundDecel,
        GroundDecel
    );

    if (VSpeed > 0)
    {
        VSpeed = 0;
        VSubPixel = 0;
    }
}
else
{
    VSpeed = min(
        VSpeed + Gravity,
        MaxFallSpeed
    );
}

//Convertir movimiento horizontal a píxeles
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
        if (!CheckSolid(x + StepX, y))
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

//Convertir movimiento vertical a píxeles
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
        var VerticalBlocked = CheckSolid(
            x,
            y + StepY
        );

        if (!VerticalBlocked && StepY > 0)
        {
            VerticalBlocked = CheckSemi(
                x,
                y + StepY
            );
        }

        if (!VerticalBlocked)
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

//Actualizar apoyo después del desplazamiento
OnGround = CheckGround();