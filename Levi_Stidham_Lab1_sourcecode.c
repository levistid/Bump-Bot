
/*********************************************************
 * Levi_Stidham_Lab1_sourcecode.c
 * 
 * Levi Stidham
 * Date: Jan 25, 2024
This code will cause a TekBot connected to the AVR board to
move forward and when it touches an obstacle, it will reverse
and turn away from the obstacle and resume forward motion.

PORT MAP
Port B, Pin 5 -> Output -> Right Motor Enable
Port B, Pin 4 -> Output -> Right Motor Direction
Port B, Pin 6 -> Output -> Left Motor Enable
Port B, Pin 7 -> Output -> Left Motor Direction
Port D, Pin 5 -> Input -> Left Whisker
Port D, Pin 4 -> Input -> Right Whisker
*/

#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

//this function causes the tekbot to go through the basic bumpbot routine
void movement(){
   PORTB = 0b10010000; //moves tekbot forward
   _delay_ms(500);       //delays 500 ms
   PORTB = 0b11110000; //halt the tekbot
   _delay_ms(500);     //delays 500 ms
   PORTB= 0b00000000; //reverse the tekbot
   _delay_ms(500);      //delay 500 ms
   PORTB = 0b00100000;  //turns tekbot to the right
   _delay_ms(2000);    //delay 2 seconds
   PORTB = 0b0001000;   //turns tekbot left
   _delay_ms(1000);      //delay 1 second

}

//This function runs the tekbot through the right whisker activated part of the brief.
void whisker_right(){
      _delay_ms(500);   //delay for 500 ms
      PORTB = 0b11110000; //cause the tekbot to halt
       _delay_ms(500);   // delay for 500 ms
      PORTB = 0b00000000; // Cause the tekbot to reverse
       _delay_ms(1000);     // delay for 1 sec
      PORTB = 0b0001000;  // Tekbot turns left
      _delay_ms(1000);       //delay 1 sec
      PORTB= 0b10010000;      //send the tekbot forward again

 }

//this function runs the tekbot through the left whisker activated part of the brief
void whisker_left(){    
      _delay_ms(500);   //delay for 500 ms
      PORTB = 0b11110000; //cause the tekbot to halt
       _delay_ms(500);   // delay for 500 ms
      PORTB = 0b00000000; // Cause the tekbot to reverse
       _delay_ms(1000);     // delay for 1 sec
      PORTB = 0b0010000;  // Tekbot turns right
      _delay_ms(1000);       //delay 1 sec
      PORTB= 0b10010000;      //send the tekbot forward again
}

int main(void)
{
      DDRB = 0b11111111;  //This configures the Port B pins for output signals
      PORTB = 0b11110000; // Set all the initial values high for port B, which disables both motors to begin
      DDRD =  0b00000000; // Set all port D pins for input signals
      PORTD = 0b11111111; //Set initial values high for port D left and right whisker inputs
      // IN mpr, PIND; //read input data to mpr
      uint8_t mpr = PIND & 0b00110000; //read and extract only the 4th and 5th bits

while (1) // loop forever
      {
            
	      PORTB = 0b10010000; //Moves tekbot forward            
            if(mpr == 0b00000000){  //Tekbot hit both whiskers at the same time, 
                  whisker_right(); //pauses, reverse, and turns tekbot to the left
            }
            else 
            if(mpr == 0b00100000){  //Right whisker activated
                 whisker_right();   //proceedure for right whisker activation

            }
            PORTB = 0b10010000; //moves tekbot forward
            if(PORTD = 0b00001000) //Left whisker activated
             {
               whisker_left(); //proceedure for left whisker activation
             }

            
      }

 
}
