# thanks_for_playing_screen.py
import pygame
import sys

def thanks_for_playing_screen(screen):
    """Show the playing screen"""
    thanks_for_playing_image = pygame.image.load("images/thanks-for-playing-screen.png").convert_alpha()

    # Resize the image to 50% of its original size
    new_size = (thanks_for_playing_image.get_width() // 2, thanks_for_playing_image.get_height() // 2)
    thanks_for_playing_image_decreased = pygame.transform.scale(thanks_for_playing_image, new_size)

    while True:
        thanks_rect = thanks_for_playing_image_decreased.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2))
        screen.blit(thanks_for_playing_image_decreased, thanks_rect)

        pygame.display.flip()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                return
