# controls_screen.py
import pygame
import sys

def controls_screen(screen):
    """Show the controls screen"""
    controls_image = pygame.image.load("images/controls-white.png").convert_alpha() # For White Background

    while True:
        title_rect = controls_image.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 - 20))
        screen.blit(controls_image, title_rect)

        pygame.display.flip()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                return
