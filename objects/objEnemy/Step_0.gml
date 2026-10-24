/// @description Actualiza el estado, movimiento y colisiones del enemigo

//Resolver la desaparición inesperada del portador
if (Carrier != noone && !instance_exists(Carrier))
{
    ChangeState(ENEMY_STATE.FLATTENED);
}

//Comprobar el suelo
OnGround = place_meeting(x, y + 1, objSolid);

//Actualizar temporizador
StateTimer += 1;

//Ejecutar el estado actual
switch (EnemyState)
{
    case ENEMY_STATE.NORMAL:
        UpdateNormalState();
        break;

    case ENEMY_STATE.FLATTENED:
        UpdateFlattenedState();
        break;

    case ENEMY_STATE.WAKING:
        UpdateWakingState();
        break;
    
    case ENEMY_STATE.CARRIED:
        UpdateCarriedState();
        break;

    default:
        HSpeed = 0;
        break;
}

//El portador controla la posición del enemigo sujeto
if (instance_exists(Carrier))
{
    HSpeed = 0;
    VSpeed = 0;

    HSubPixel = 0;
    VSubPixel = 0;

    OnGround = false;
    image_xscale = 1;

    exit;
}

//Aplicar gravedad
if (UsesGravity && !OnGround)
{
    VSpeed = min(
        VSpeed + Gravity,
        MaxFallSpeed
    );
}
else if (OnGround && VSpeed > 0)
{
    VSpeed = 0;
}

//Convertir movimiento horizontal
HSubPixel += HSpeed;

var MoveX =
    floor(abs(HSubPixel))
    * sign(HSubPixel);

HSubPixel -= MoveX;

//Resolver colisiones horizontales
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

            OnWallHit();
            break;
        }
    }
}

//Convertir movimiento vertical
VSubPixel += VSpeed;

var MoveY =
    floor(abs(VSubPixel))
    * sign(VSubPixel);

VSubPixel -= MoveY;

//Resolver colisiones verticales
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

//Actualizar condiciones
OnGround = place_meeting(x, y + 1, objSolid);

//Comprobar contacto dañino con el jugador
if (
    EnemyState == ENEMY_STATE.NORMAL
    && ContactDamage > 0
)
{
    var Player = instance_place(
        x,
        y,
        objPlayer
    );

    if (Player != noone)
    {
        //Calcular los centros de las máscaras
        var EnemyCenterX =
            (bbox_left + bbox_right) * 0.5;

        var PlayerCenterX =
            (Player.bbox_left + Player.bbox_right) * 0.5;

        //Determinar de qué lado se encuentra el jugador
        var PlayerSide = sign(
            PlayerCenterX - EnemyCenterX
        );

        //Resolver el caso en que ambos centros coincidan
        if (PlayerSide == 0)
        {
            PlayerSide = -Facing;
        }

        var DamageApplied =
            Player.TakeDamage(
                ContactDamage,
                EnemyCenterX
            );

        if (DamageApplied)
        {
            OnPlayerDamaged(
                Player,
                PlayerSide
            );
        }
    }
}

//Orientar el sprite según su estado
if (
    EnemyState == ENEMY_STATE.FLATTENED
    || EnemyState == ENEMY_STATE.WAKING
    || EnemyState == ENEMY_STATE.CARRIED
)
{
    image_xscale = 1;
}
else
{
    image_xscale = Facing;
}
