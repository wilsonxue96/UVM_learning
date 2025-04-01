// 定义时间单位和时间精度
// 时间单位是1ns，时间精度是1ps
`timescale 1ns/1ps

// 包含UVM宏定义文件
// uvm_macros.svh中定义了UVM的宏（如`uvm_info等）
`include "uvm_macros.svh"

// 导入UVM库
// uvm_pkg是UVM的核心库，包含了UVM的所有类和函数
import uvm_pkg::*;

// 包含自定义的my_driver.sv文件
// my_driver.sv中定义了my_driver类
`include "my_driver.sv"

// 定义顶层测试模块top_tb
module top_tb;

   // 定义时钟信号clk
   reg clk;

   // 定义复位信号rst_n（低电平有效）
   reg rst_n;

   // 定义8位接收数据信号rxd
   reg[7:0] rxd;

   // 定义接收数据有效信号rx_dv
   reg rx_dv;

   // 定义8位发送数据信号txd
   wire[7:0] txd;

   // 定义发送数据有效信号tx_en
   wire tx_en;

   // 实例化DUT（Design Under Test，待测设计）
   // 将测试平台的信号连接到DUT的端口
   dut my_dut(
      .clk(clk),
      .rst_n(rst_n),
      .rxd(rxd),
      .rx_dv(rx_dv),
      .txd(txd),
      .tx_en(tx_en)
   );

   // 初始化块1：用于创建和启动my_driver对象
   initial begin
      // 声明my_driver类型的变量drv
      my_driver drv;

      // 创建my_driver对象，传入名称"drv"和父组件null
      drv = new("drv", null);

      // 调用my_driver的main_phase任务，传入null作为phase参数
      drv.main_phase(null);

      // 结束仿真
      $finish();
   end

   // 初始化块2：用于生成时钟信号
   initial begin
      // 初始化时钟信号clk为0
      clk = 0;

      // 无限循环，每隔100个时间单位翻转一次时钟信号
      forever begin
         #100 clk = ~clk;
      end
   end

   // 初始化块3：用于生成复位信号
   initial begin
      // 初始化复位信号rst_n为0（复位状态）
      rst_n = 1'b0;

      // 等待1000个时间单位
      #1000;

      // 将复位信号rst_n置为1（退出复位状态）
      rst_n = 1'b1;
   end

endmodule
