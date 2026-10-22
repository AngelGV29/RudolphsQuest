/// @description Dibuja al jugador y la hitbox de prueba

draw_self();

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