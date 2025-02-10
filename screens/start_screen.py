# start_screen.py
import pygame
import sys

def start_screen(screen):
    """Show the initial start screen."""
    # title_text = large_font.render("2D Running Game", True, (255, 255, 255))
    # start_text = large_font.render("Press any key to start", True, (255, 255, 255))

    title_image = pygame.image.load("images/title.png").convert_alpha()

    while True:
        # screen.fill((32, 32, 32))  # Black background
        # screen.blit(title_text, title_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 - 50)))
        # screen.blit(start_text, start_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 + 50)))

        title_rect = title_image.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 - 50))
        screen.blit(title_image, title_rect)

        pygame.display.flip()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                return
