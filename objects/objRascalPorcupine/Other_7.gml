/// @description Mantiene la última pose de defensa

if (
    BlockActive
    && sprite_index == StateSpriteBlock
)
{
    image_index = image_number - 1;
    image_speed = 0;
}