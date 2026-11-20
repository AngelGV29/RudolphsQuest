/// @description Conserva la pose final de muerte

if (
    ActionState == PLAYER_ACTION_STATE.DEAD
    && sprite_index == DeathSprite
)
{
    image_index = image_number - 1;
    image_speed = 0;

    DeathAnimationFinished = true;
}