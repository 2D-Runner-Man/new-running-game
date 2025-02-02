# game_over_screen.py
import pygame
import sys

def game_over_screen(screen, font, large_font):
    """Display a Game Over screen."""
    game_over_text = large_font.render("Game Over", True, (255, 0, 0))
    exit_text = font.render("Press any key to exit", True, (255, 255, 255))
    while True:
        screen.fill((32, 32, 32))  # Black background
        screen.blit(game_over_text, game_over_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 - 50)))
        screen.blit(exit_text, exit_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 + 50)))
        pygame.display.flip()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                pygame.quit()
                sys.exit()
