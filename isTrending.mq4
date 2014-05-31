//+------------------------------------------------------------------+
//|                                                   lookBack_4.mq4 |
//| rysuje linie dziennego Hi/Lo dla ka¿dej timeframe                |
//| badany zakres jest funkcj¹ pochodnej zmiennoœci                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, chew-z"
#property link      "isTrending - based on daily MA crossover"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green    // Color of the Long line
#property indicator_color2 Red      // Color of the Short line
//---- indicator parameters
extern int K = 4;  //czwartego dnia a nie po czterech dniach
extern int minPeriod = 5;
extern int maxPeriod = 20;
//---- buffers
double ShortBuffer[];
double LongBuffer[];
//--- parameters
int S, L;

int init()
  {
   SetIndexBuffer(0,LongBuffer); 
   SetIndexBuffer(1,ShortBuffer);
   SetIndexStyle (1,DRAW_LINE,STYLE_SOLID, 2);
   SetIndexStyle (0,DRAW_LINE,STYLE_SOLID, 2);
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
   // Teraz sprawdzamy isTrending
      S = isTrending_S(i);
      L = isTrending_L(i);
      ShortBuffer[i] = S;
      LongBuffer[i] = L;
      i--; 
   } // while
   return(0); // exit
}

int deinit()     {
   return(0); // exit
}
/////////////////////////// SIGNALS ////////////////////////////////////
bool isTrending_L(int j) { // Czy œrednia szybka powy¿ej wolnej?
int i;
double M;
int sig = 0;
   for (i = K; i>-1; i--) {
      M = iMA(NULL,PERIOD_D1,maxPeriod,i,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0);
      if (iMA(NULL,PERIOD_D1,minPeriod,i,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0) > M)
         sig++;
   }
   if(sig < K)
      return(false);
   else 
      return(true);
}
bool isTrending_S(int j) { // Czy œrednia szybka poni¿ej wolnej?
int i;
double M;
int sig = 0;
   for (i = K; i>-1; i--) {
      M = iMA(NULL,PERIOD_D1,maxPeriod,i,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0);
      if (iMA(NULL,PERIOD_D1,minPeriod,i,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0) < M)
         sig++;
   }
   if(sig < K)
      return(false);
   else 
      return(true);
}