//+------------------------------------------------------------------+
//|                                        trendline_4.mq4          |
//| rysuje linie trendu w oparciu o regresję liniową                 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014-2015, chew-z"
#property link      "trendline_4"
#include <TradeTools\TradeTools5.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue   // Color of the High trendline
#property indicator_color2 Orange   // Color of the Low trendline
#property indicator_color3 Red
//---- indicator parameters
extern int rangeX = 20;
//---- buffers
double Low1Buffer[];
double High1Buffer[];
double N1Buffer[];
//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
datetime       LastAlertTime            = -999999;
datetime       LastRedrawTime           = -999999;
string         AlertTextCrossUp         = " trendline cross UP";
string         AlertTextCrossDown       = " trendline cross DOWN";

int OnInit()    {
    AlertEmailSubject = Symbol() + " trendline alert";
    LastAlertTime = Time[0]; //experimental - supresses series of crazy alerts sent after terminal start

    GlobalVariableSet(StringConcatenate(Symbol(), "_trendline"), 0);

    SetIndexBuffer(2, N1Buffer);
    SetIndexBuffer(1, Low1Buffer);
    SetIndexBuffer(0, High1Buffer);

    SetIndexStyle (2, DRAW_LINE,STYLE_DASH, 1);
    SetIndexStyle (1, DRAW_LINE,STYLE_DASH, 1);
    SetIndexStyle (0, DRAW_LINE,STYLE_DASH, 1);

    SetIndexDrawBegin(2, 0);
    SetIndexDrawBegin(1, 0);
    SetIndexDrawBegin(0, 0);
    if( !IsConnected() )
        Sleep( 5000 );  //wait 5s for establishing connection to trading server
    //Sleep() is automatically passed during testing
    return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason){
   GlobalVariableDel(StringConcatenate(Symbol(), "_trendline"));
   Print(__FUNCTION__,"_Deinitalization reason code = ", getDeinitReasonText(reason));
   }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])        {

// Print(rates_total+" : "+prev_calculated);
// repaint only on new bar, chart refresh etc.
// http://forum.mql4.com/64114
if (prev_calculated != rates_total) {
    // universal counter variable
    int c = rangeX;
    // clear last drawing
    for(c = rangeX+1; c>=0; c--) {
        High1Buffer[c] = EMPTY_VALUE;
        Low1Buffer[c] = EMPTY_VALUE;
    }
    // to be able to set array size based on variable,
    // make a dynamically sized array
    double X_arr[];
    double H_arr[];
    double L_arr[];
    ArrayResize(X_arr, rangeX);
    ArrayResize(H_arr, rangeX);
    ArrayResize(L_arr, rangeX);
// Fill in arrays
    ArrayCopy( H_arr, high, 0, 0, rangeX);
    ArrayCopy( L_arr, low, 0, 0, rangeX);
    for(c = rangeX; c>=0; c--)
        X_arr[c] = c;
// This puts array in normal order [left..right]
    ArraySetAsSeries(H_arr, false);
    ArraySetAsSeries(L_arr, false);
// Tu trzeba jeszcze poeksperymentować z indeksowaniem (0, 1.. N-1, N)
/*    for(c rangeX; c >= 0; c--){
       Print(c + " : " + H_arr[c]);
        Print(c + " : " + X_arr[c]);
        } */
    double m_X = mean(X_arr);  // [0..N-1]
    double m_Y_H = mean(H_arr);
    double m_Y_L = mean(L_arr);
    double r_H = rho(X_arr, H_arr);
    double r_L = rho(X_arr, L_arr);
    double b_H = r_H * (std(H_arr) / std(X_arr));
    // Print(std(H_arr)+ " : " + std(X_arr));
    double b_L = r_L * (std(L_arr) / std(X_arr));
    // Print(std(rangeX, L_arr)+ " : " + std_X(rangeX));
    double A_H = m_Y_H - b_H * m_X;
    double A_L = m_Y_L - b_L * m_X;

    Print ("m_X: "+m_X+" m_Y_H: "+m_Y_H+" b: "+b_H+" A: "+ A_H+" r: "+r_H);
    Print ("m_X: "+m_X+" m_Y_L: "+m_Y_L+" b: "+b_L+" A: "+ A_L+" r: "+r_L);
    c = rangeX;
    while(c >= 0)    {
            // Print(line(i, b_H, A_H)+"\t"+line(i, b_L, A_L));
            High1Buffer[c]  = line(c, b_H, A_H);
            Low1Buffer[c] = line(c, b_L, A_L);
        c--;
      } // while
} //prev_calc
    return(rates_total);
}

double line(double x, double b, double A) {
    return b * x + A;
}

double rho(double & x[], double & a[]) {
    // [1..N-1]
    int N = ArrayRange(a, 0);
    double m_X = mean(x); //sum of arithmetic progression
    double m_Y = mean(a);
    double sum_xy = 0.0;
    double sum_sq_v_x = 0.0;
    double sum_sq_v_y = 0.0;

    for(int j = N-1; j > 0; j--) {
        double var_x = j - m_X;
        double var_y = a[j] - m_Y;
        sum_xy += var_x * var_y;
        sum_sq_v_x += MathPow(var_x, 2);
        sum_sq_v_y += MathPow(var_y, 2);
    }
    return sum_xy / MathSqrt(sum_sq_v_x * sum_sq_v_y);
}

double mean(double & a[]) {
    // [1..N-1]
    int N = ArrayRange(a, 0);
    double sigma = 0.0;
    for(int j = N-1; j > 0; j--) {
        sigma += a[j];
    }
    return(sigma / (N-1));
}

double std(double & a[]) {
    // [1..N-1]
    int N = ArrayRange(a, 0);
    double m = mean(a);
    double sigma = 0.0;
    for(int j = N-1; j > 0; j--) {
        sigma += MathPow(a[j] - m, 2);
    }
    int normalizer = N - 2;
    return (MathSqrt(sigma) / normalizer);
}

