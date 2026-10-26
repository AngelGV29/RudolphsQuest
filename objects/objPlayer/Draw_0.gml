/// @description Dibuja al jugador y la hitbox de prueba

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

//Dibuja la hitbox que abarca el martillazo
if (ShowHammerHitbox && HammerActive)
{
    draw_set_alpha(0.35);
    draw_set_color(c_red);

    draw_rectangle(
        HammerHitLeft,
        HammerHitTop,
        HammerHitRight,
        HammerHitBottom,
        false
    );

    draw_set_alpha(1);
    draw_set_color(c_white);
}