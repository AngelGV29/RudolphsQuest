/// @description Dibuja al jugador y la hitbox de prueba

//Dibujar locomoción normal
if (ActionState != PLAYER_ACTION_STATE.HAMMER)
{
    draw_self();
}
else
{
    //Obtener dimensiones y origen del sprite de locomoción
    var BodyWidth = sprite_get_width(sprite_index);
    var BodyHeight = sprite_get_height(sprite_index);

    var OriginX = sprite_get_xoffset(sprite_index);
    var OriginY = sprite_get_yoffset(sprite_index);

    //Alinear la parte inferior con el origen del personaje
    var DrawX = x - OriginX * image_xscale;
    var DrawY =
        y + (BodySplitY - OriginY) * image_yscale;

    //Dibujar piernas con su fotograma de locomoción
    draw_sprite_part_ext(
        sprite_index,
        floor(image_index),
        0,
        BodySplitY,
        BodyWidth,
        BodyHeight - BodySplitY,
        DrawX,
        DrawY,
        image_xscale,
        image_yscale,
        image_blend,
        image_alpha
    );

    //Dibujar torso y martillo con un fotograma independiente
    draw_sprite_ext(
        HammerUpperSprite,
        floor(HammerUpperFrame),
        x,
        y,
        HammerFacing,
        image_yscale,
        0,
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