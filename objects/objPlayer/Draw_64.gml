/// @description Muestra temporalmente la vida del jugador

draw_set_alpha(1);
draw_set_color(c_white);

draw_text(
    8,
    8,
    "HP: "
    + string(Hp)
    + "/"
    + string(MaxHp)
);