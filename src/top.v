/*
* VGA test using the tang nano 9k
* Copyright (C) 2023  Gustavo Alpern
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

module vga (
    input sys_clk,
    output reg R,
    output reg G,
    output reg B,
    output reg hsync =1,
    output reg vsync =1
    
);  
////////////////////////////REGISTROS O WIRE GLOBALES/////////////////////////
wire pixelclk; //clock pixel
    reg modrojo; //buffer rojo
    reg modverde; //buffer verde
    reg modazul; //buffer azul
    reg [24:0] contadortiempo; //contador tiempo en base del clock de 27MHZ
    reg signed [11:0] contadorpixel; //contador de pixeles en eje X
    reg signed [11:0] contadorvertical;//contador de pixeles en eje Y
    reg [9:0] cuentarebotes[0:2];
    reg [2:0]colores;
    reg signed [10:0] x[0:2]; //variable x
    reg signed [10:0] y[0:2]; //variable y
    reg signed [4:0] sumax[0:2]; //variable sumax
    reg signed [4:0] sumay[0:2]; //variable sumay
/////////////////////////////Inicio/////////////////////////////////////////////
initial begin
        cuentarebotes[0] =0;
        cuentarebotes[1] =0;
        cuentarebotes[2] =0;
        x[0]=10'd60;
        x[1]=10'd600;
        x[2]=10'd400;
        y[0]=10'd300;
        y[1]=10'd500;
        y[2]=10'd700;
        sumax[0]=4'd2;
        sumax[1]=4'd3;
        sumax[2]=4'd4;
        sumay[0]=4'd2;
        sumay[1]=4'd3;
        sumay[2]=4'd4;
    end
/////////////////////////////FUNCIONES////////////////////////////////////////////
    function linea(input signed [44:0]countx,county,x1,y1,x2,y2);
        begin
            //if(x1!=x2)begin
                if(((county - y2)*(x2-x1))>>8 == ((y2-y1)*(countx-x2))>>8) begin
                    if(x1<x2&&y1>y2&&countx>x1&&countx<x2&&county<y1&&county>y2)begin
                        linea=1;
                    end
                    else if(x1>x2&&y1>y2&&countx>x2&&countx<x1&&county<y1&&county>y2) begin
                        linea=1;
                    end
                    else if(x1<x2&&y1<y2&&countx>x1&&countx<x2&&county<y2&&county>y1) begin
                        linea=1;
                    end
                    else if(x1>x2&&y1<y2&&countx>x2&&countx<x1&&county<y2&&county>y1) begin
                        linea=1;
                    end
                    else begin
                        linea=0;
                    end
                    
                end
                else begin
                linea=0;
                end
            /*end 
            else if(x1==x2)begin
                if(y1>y2&&rectangulo(countx,county,x1,x2,y2,y1))begin
                    linea=1;
                end
                else if(y1<y2&&rectangulo(countx,county,x1,x2,y1,y2))begin
                    linea=1;
                end
                else begin
                    linea=0;
                end
            end
            else if(y1==y2)begin
                if(x1>x2&&rectangulo(countx,county,x2,x1,y2,y1))begin
                    linea=1;
                end
                else if(x1<x2&&rectangulo(countx,county,x1,x2,y1,y2))begin
                    linea=1;
                end
                else begin
                    linea=0;
                end
            end
            else begin
                linea=0;
            end*/

        end
    endfunction
    function circulo(input signed [22:0] countx,county,posx,posy,input signed [20:0] r);
        begin
            if((countx-posx)*(countx-posx)+(county-posy)*(county-posy)<r*r)begin
                circulo=1;
            end
            else begin
                circulo=0;
            end
        end
    endfunction
    function rectangulo(input [10:0] countx,county,minx,maxx,miny,maxy);
        begin
            if(countx >= minx &&countx <maxx && county >= miny &&county <maxy)begin
                rectangulo=1;
            end
            else begin
                rectangulo=0;
            end
        end
    endfunction
    
    function num0(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+10*scale,posy,posy+2*scale))begin
                num0=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+15*scale,posy+2*scale+15*scale))begin
                num0=1;
            end
            else if(rectangulo(countx,county,posx,posx+2*scale,posy,posy+2*scale+15*scale))begin
                num0=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy,posy+2*scale+15*scale))begin
                num0=1;
            end
            else begin
                num0=0;
            end
        end
    endfunction
    function num1(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy,posy+2*scale+15*scale))begin
                num1=1;
            end
            else begin
                num1=0;
            end
        end
    endfunction
    function num2(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+10*scale,posy,posy+2*scale))begin
                num2=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+15*scale,posy+2*scale+15*scale))begin
                num2=1;
            end
            else if(rectangulo(countx,county,posx,posx+2*scale,posy+(2*scale+15*scale)/2,posy+2*scale+15*scale))begin
                num2=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy,posy+(2*scale+15*scale)/2))begin
                num2=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+(15*scale)/2,posy+(4*scale+15*scale)/2))begin
                num2=1;
            end
            else begin
                num2=0;
            end
        end
    endfunction
    function num3(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+10*scale,posy,posy+2*scale))begin
                num3=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+15*scale,posy+2*scale+15*scale))begin
                num3=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy,posy+2*scale+15*scale))begin
                num3=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+(15*scale)/2,posy+(4*scale+15*scale)/2))begin
                num3=1;
            end
            else begin
                num3=0;
            end
        end
    endfunction
    function num4(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+2*scale,posy,posy+(2*scale+15*scale)/2))begin
                num4=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy,posy+2*scale+15*scale))begin
                num4=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+(15*scale)/2,posy+(4*scale+15*scale)/2))begin
                num4=1;
            end
            else begin
                num4=0;
            end
        end
    endfunction
    function num5(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+10*scale,posy,posy+2*scale))begin
                num5=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+15*scale,posy+2*scale+15*scale))begin
                num5=1;
            end
            else if(rectangulo(countx,county,posx,posx+2*scale,posy,posy+(2*scale+15*scale)/2))begin
                num5=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy+(2*scale+15*scale)/2,posy+2*scale+15*scale))begin
                num5=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+(15*scale)/2,posy+(4*scale+15*scale)/2))begin
                num5=1;
            end
            else begin
                num5=0;
            end
        end
    endfunction
    function num6(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+10*scale,posy,posy+2*scale))begin
                num6=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+15*scale,posy+2*scale+15*scale))begin
                num6=1;
            end
            else if(rectangulo(countx,county,posx,posx+2*scale,posy,posy+2*scale+15*scale))begin
                num6=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy+(2*scale+15*scale)/2,posy+2*scale+15*scale))begin
                num6=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+(15*scale)/2,posy+(4*scale+15*scale)/2))begin
                num6=1;
            end
            else begin
                num6=0;
            end
        end
    endfunction
    function num7(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+10*scale,posy,posy+2*scale))begin
                num7=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy,posy+2*scale+15*scale))begin
                num7=1;
            end
            else begin
                num7=0;
            end
        end
    endfunction
    function num8(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+10*scale,posy,posy+2*scale))begin
                num8=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+15*scale,posy+2*scale+15*scale))begin
                num8=1;
            end
            else if(rectangulo(countx,county,posx,posx+2*scale,posy,posy+2*scale+15*scale))begin
                num8=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy,posy+2*scale+15*scale))begin
                num8=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+(15*scale)/2,posy+(4*scale+15*scale)/2))begin
                num8=1;
            end
            else begin
                num8=0;
            end
        end
    endfunction
    function num9(input [10:0] countx,county,posx,posy,scale);
        begin
            if(rectangulo(countx,county,posx,posx+10*scale,posy,posy+2*scale))begin
                num9=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+15*scale,posy+2*scale+15*scale))begin
                num9=1;
            end
            else if(rectangulo(countx,county,posx,posx+2*scale,posy,posy+(2*scale+15*scale)/2))begin
                num9=1;
            end
            else if(rectangulo(countx,county,posx+10*scale-2*scale,posx+10*scale,posy,posy+2*scale+15*scale))begin
                num9=1;
            end
            else if(rectangulo(countx,county,posx,posx+10*scale,posy+(15*scale)/2,posy+(4*scale+15*scale)/2))begin
                num9=1;
            end
            else begin
                num9=0;
            end
        end
    endfunction
    function contadordenumeros(input [10:0] countx,county,posx,posy,scale,num);
        begin
            case(num)
                0:begin
                    if(num0(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                1:begin
                    if(num1(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                2:begin
                    if(num2(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                3:begin
                    if(num3(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                4:begin
                    if(num4(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                5:begin
                    if(num5(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                6:begin
                    if(num6(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                7:begin
                    if(num7(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                8:begin
                    if(num8(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                9:begin
                    if(num9(countx,county,posx,posy,scale))
                        contadordenumeros=1;
                    else
                        contadordenumeros=0;
                end
                default:contadordenumeros = 0;
            endcase
        end
    endfunction
    function contador999(input [10:0] countx,county,posx,posy,scale,num);
        begin
            if(num<10)begin
                if(contadordenumeros(countx,county,posx,posy,scale,num))begin
                    contador999=1;
                end
                else begin
                    contador999=0;
                end
            end
            else if(num<100&&num>9)begin
                if(contadordenumeros(countx,county,posx+11*scale,posy,scale,num%10))begin
                    contador999=1;
                end
                else if(contadordenumeros(countx,county,posx,posy,scale,num/10))begin
                    contador999=1;
                end
                else begin
                    contador999=0;
                end
            end
            else if(num<1000&&num>99)begin
                if(contadordenumeros(countx,county,posx+22*scale,posy,scale,(num%10)%10))begin
                    contador999=1;
                end
                else if(contadordenumeros(countx,county,posx+11*scale,posy,scale,(num%100)/10))begin
                    contador999=1;
                end
                else if(contadordenumeros(countx,county,posx,posy,scale,num/100))begin
                    contador999=1;
                end
                else begin
                    contador999=0;
                end
            end
            else begin
                contador999=0;
            end
        end
    endfunction
////////////////////////Generacion de señal//////////////////////////////////
    Gowin_rPLL pixeles(   //PLL A 75MHZ para generar el pixel clk
        .clkout(pixelclk), //output clkout
        .clkin(sys_clk) //input clkin
    );
    
    always @(posedge pixelclk) begin //generacion de vga
        if(contadorpixel < 1024)begin //tiempo en pantalla
            R<= modrojo;
            G<= modverde;
            B<= modazul;
            contadorpixel <= contadorpixel +1;
        end
        else if(contadorpixel > 1023 &&  contadorpixel<1048 )begin
            R<= 0;
            G<= 0;
            B<= 0;
            contadorpixel <= contadorpixel +1;
        end
        else if(contadorpixel > 1047 &&  contadorpixel<1184 )begin
            hsync <= 0;
            contadorpixel <= contadorpixel +1;
        end
        else if(contadorpixel > 1183 &&  contadorpixel<1328 )begin
            hsync <= 1;
            contadorpixel <= contadorpixel +1;
        end
        else begin
            contadorpixel <=0;
            if(contadorvertical < 768)begin
                contadorvertical <=  contadorvertical + 1;
            end
            else if(contadorvertical > 767 &&  contadorvertical<770 )begin
                R<= 0;
                G<= 0;
                B<= 0;
                contadorvertical <=  contadorvertical + 1;
            end
            else if(contadorvertical > 769 &&  contadorvertical<776 )begin
                vsync <= 0;
                contadorvertical <=  contadorvertical + 1;
            end
            else if(contadorvertical > 775 &&  contadorvertical<806 )begin
                vsync <= 1;
                contadorvertical <=  contadorvertical + 1;
            end
            else begin
                contadorvertical <=  0;
            end
        end
        
    end
/////////////////////////////////Zona de dibujo/////////////////////////////////
    always @(posedge pixelclk) begin
        if(circulo(contadorpixel,contadorvertical,x[0],y[0],50))begin
            modrojo <= 1;
            modazul <= 0;
            modverde <= 0;
        end
        else if(circulo(contadorpixel,contadorvertical,x[1],y[1],50))begin
            
            modrojo <= 0;
            modverde <= 1;
            modazul <= 0;
        end
        else if(circulo(contadorpixel,contadorvertical,x[2],y[2],50))begin
            modazul <= 1;
            modverde <= 0;
            modrojo <= 0;
        end
        else if(rectangulo(contadorpixel,contadorvertical,0,1024,200,210)||rectangulo(contadorpixel,contadorvertical,0,1024,758,768)||rectangulo(contadorpixel,contadorvertical,0,10,200,768)||rectangulo(contadorpixel,contadorvertical,1014,1024,200,768))begin
            case(colores)
                0:begin
                    modrojo <= 1;
                    modazul <= 0;
                    modverde <= 0;
                end
                1:begin
                    modrojo <= 0;
                    modazul <= 0;
                    modverde <= 1;
                end
                2:begin
                    modrojo <= 0;
                    modazul <= 1;
                    modverde <= 0;
                end
                default: begin
                    modrojo <= 1;
                    modazul <= 1;
                    modverde <= 1;
                end
            endcase
        end
        else if(contador999(contadorpixel,contadorvertical,1,20,8,cuentarebotes[0]))begin
            modrojo <= 1;
            modazul <= 0;
            modverde <= 0;
        end
        else if(contador999(contadorpixel,contadorvertical,350,20,8,cuentarebotes[1]))begin
            modrojo <= 0;
            modazul <= 0;
            modverde <= 1;
        end
        else if(contador999(contadorpixel,contadorvertical,700,20,8,cuentarebotes[2]))begin
            modrojo <= 0;
            modazul <= 1;
            modverde <= 0;
        end
        else if(linea(contadorpixel,contadorvertical,x[0],y[0],x[1],y[1])) begin
            modrojo <= 1;
            modazul <= 1;
            modverde <= 1;
        end
        else if(linea(contadorpixel,contadorvertical,x[1],y[1],x[2],y[2])) begin
            modrojo <= 1;
            modazul <= 1;
            modverde <= 1;
        end
        else if(linea(contadorpixel,contadorvertical,x[0],y[0],x[2],y[2])) begin
            modrojo <= 1;
            modazul <= 1;
            modverde <= 1;
        end
        else begin
            modrojo <= 0;
            modazul <= 0;
            modverde <= 0;
        end
    end
    always @(posedge sys_clk) begin 
        if(contadortiempo< 24'd135000) begin
            contadortiempo <= contadortiempo +1;
        end
        else begin
            
            for(integer i=0;i<3;i=i+1)begin
                x[i] =x[i] + sumax[i];
                y[i] =y[i] + sumay[i];
                if(x[i]<50 || x[i]>964)begin
                    sumax[i] = -sumax[i];
                    cuentarebotes[i] = cuentarebotes[i]+1;
                    colores <= i; 
                end
                if(y[i]<261 || y[i]>708)begin
                    sumay[i] = -sumay[i];
                    colores <= i; 
                    cuentarebotes[i] = cuentarebotes[i]+1;
                end
            end
            contadortiempo <=0;
        end
    end
endmodule