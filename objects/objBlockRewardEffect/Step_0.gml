/// @description Eleva y desvanece la recompensa visual

y -= RiseSpeed;

EffectTimer += 1;

image_alpha = max(
    0,
    1 - EffectTimer / max(1, EffectFrames)
);

if (EffectTimer >= EffectFrames)
{
    instance_destroy();
}