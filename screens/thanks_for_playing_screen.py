# thanks_for_playing_screen.py
import pygame
import sys
import math

def thanks_for_playing_screen(screen, large_font, extra_large_font, score):
    """Show the thanks for playing screen"""

    score_text = extra_large_font.render(f"Your score is: {score}" , True, (255, 255, 255))
    thanks_for_playing_text = large_font.render("Thanks for Playing!", True, (255, 255, 255))
    thanks_for_playing_image = pygame.image.load("images/thanks-for-playing-screen.png").convert_alpha()

    clock = pygame.time.Clock()
    start_time = pygame.time.get_ticks()  # Get the initial time

    # Resize the image to 50% of its original size
    new_size = (thanks_for_playing_image.get_width() // 2, thanks_for_playing_image.get_height() // 2)
    thanks_for_playing_image_decreased = pygame.transform.scale(thanks_for_playing_image, new_size)
    thanks_rect = thanks_for_playing_image_decreased.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2))

    score_text_rect = score_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 - 100))

    while True:
        elapsed_time = pygame.time.get_ticks() - start_time  # Time since start
        hover_offset = int(math.sin(elapsed_time * 0.007) * 10)  # Smooth hover effect

        screen.blit(thanks_for_playing_image_decreased, thanks_rect)

        screen.blit(score_text, score_text_rect)

        thanks_for_playing_text_rect = thanks_for_playing_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 + 30 + hover_offset))
        screen.blit(thanks_for_playing_text, thanks_for_playing_text_rect)
        
        pygame.display.flip()
        clock.tick(60)  # Limit frame rate

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                return
