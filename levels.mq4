//+------------------------------------------------------------------+
//|                                                   levels.mq4     |
//| rysuje dwa zadane poziomy wsparcia i oporu                       |
//| dodatkowo dodam alerty                                           |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, chew-z"
#property link      "levels - "

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red      // Color of the High line 2
#property indicator_color2 Red      // Color of the High line 1
#property indicator_color3 Green    // Color of the Low line 1
#property indicator_color4 Green    // Color of the Low line 2
//---- indicator parameters
extern double H2 = 1.31;
extern double H1 = 1.30;
extern double L1 = 1.29;
extern double L2 = 1.28;
//---- buffers
double High2Buffer[];
double High1Buffer[];
double Low1Buffer[];
double Low2Buffer[];
//--- parameters

int init()
  {
   SetIndexBuffer(3,High2Buffer);
   SetIndexBuffer(2,High1Buffer);
   SetIndexBuffer(1,Low1Buffer); 
   SetIndexBuffer(0,Low2Buffer);
   SetIndexStyle (3,DRAW_LINE,STYLE_DASHDOTDOT, 1);
   SetIndexStyle (2,DRAW_LINE,STYLE_DASHDOT, 1);
   SetIndexStyle (1,DRAW_LINE,STYLE_DASHDOT, 1);
   SetIndexStyle (0,DRAW_LINE,STYLE_DASHDOTDOT, 1);
   SetIndexDrawBegin(3,0);
   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(0,0);
   return(0);
  }

int start()    { 
   int i,                       // indeksy
       Counted_bars;            // Number of counted bars
   
   Counted_bars = IndicatorCounted();  // Number of counted bars
   i = Bars-Counted_bars-1;            // Index of the first uncounted
while(i>=0)    {                  // Loop for uncounted bars
   High2Buffer[i] = H2;
   High1Buffer[i] = H1;
   Low1Buffer[i] = L1;
   Low2Buffer[i] = L2;
   i--; 
} // while
   return(0); // exit
}
