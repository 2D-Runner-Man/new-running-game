# controls_screen.py
import pygame
import sys

def controls_screen(screen):
    """Show the controls screen with keyboard, mouse, and touch support."""

    controls_image = pygame.image.load(
        "images/controls-ios.png"
    ).convert_alpha()

    clock = pygame.time.Clock()

    while True:
        screen.fill((255, 255, 255))

        title_rect = controls_image.get_rect(
            center=(
                screen.get_width() // 2,
                screen.get_height() // 2 - 20
            )
        )

        screen.blit(controls_image, title_rect)

        pygame.display.flip()

        for event in pygame.event.get():

            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            # Continue using keyboard
            elif event.type == pygame.KEYDOWN:
                return

            # Continue using mouse (Mac testing)
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1 and not getattr(event, "touch", False):
                    return

            # Continue using touchscreen (iPhone)
            elif event.type == pygame.FINGERDOWN:
                return

        clock.tick(60)
