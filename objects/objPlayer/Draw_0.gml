/// @description Dibuja al jugador y la hitbox de prueba

//La muerte reemplaza toda la composición del jugador
if (ActionState == PLAYER_ACTION_STATE.DEAD)
{
    draw_self();
    exit;
}

//Dibujar la parte inferior
draw_sprite_ext(
    sprite_index,
    floor(image_index),
    x,
    y,
    image_xscale,
    image_yscale,
    image_angle,
    image_blend,
    image_alpha
);

//Seleccionar la parte superior
var UpperSprite = MoveUpperSprite;
var UpperFrame = floor(image_index);

if (UpperOverrideSprite != -1)
{
    UpperSprite = UpperOverrideSprite;
    UpperFrame = floor(UpperOverrideFrame);
}

//Dibujar la parte superior
if (UpperSprite != -1)
{
    draw_sprite_ext(
        UpperSprite,
        UpperFrame,
        x,
        y,
        image_xscale,
        image_yscale,
        image_angle,
        image_blend,
        image_alpha
    );
}

//Dibujar al enemigo sujeto entre el torso y el brazo
if (instance_exists(CarriedEnemy))
{
    var Enemy = CarriedEnemy;

    if (Enemy.Carrier == id)
    {
        if (Enemy.sprite_index != -1)
        {
            draw_sprite_ext(
                Enemy.sprite_index,
                floor(Enemy.image_index),
                Enemy.x,
                Enemy.y,
                Enemy.image_xscale,
                Enemy.image_yscale,
                Enemy.image_angle,
                Enemy.image_blend,
                Enemy.image_alpha * image_alpha
            );
        }

        //Dibujar la mano delante del enemigo
        draw_sprite_ext(
            sprPlayerCarryArm,
            0,
            x,
            y,
            image_xscale,
            image_yscale,
            image_angle,
            image_blend,
            image_alpha
        );
    }
}
