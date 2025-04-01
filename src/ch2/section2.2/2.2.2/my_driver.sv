// 防止文件重复包含的宏定义
// 如果MY_DRIVER__SV没有被定义过，则定义它，并编译以下代码
`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV

// 定义一个类my_driver，继承自UVM的uvm_driver类
// uvm_driver是UVM库中用于驱动DUT信号的基类
class my_driver extends uvm_driver;

   // 使用UVM的宏`uvm_component_utils注册my_driver类
   // 这个宏是UVM的工厂机制的一部分，用于支持对象的创建和配置
   `uvm_component_utils(my_driver)

   // 构造函数，用于初始化my_driver对象
   // name是驱动器的名称，parent是它的父组件（通常是uvm_agent）
   function new(string name = "my_driver", uvm_component parent = null);
      // 调用父类uvm_driver的构造函数，传入name和parent
      super.new(name, parent);

      // 使用UVM的`uvm_info宏打印一条信息，表示构造函数被调用
      // "my_driver"是消息的标签，"new is called"是消息内容，UVM_LOW是消息的详细级别
      `uvm_info("my_driver", "new is called", UVM_LOW);
   endfunction

   // 声明一个外部的任务main_phase，该任务将在UVM的main_phase阶段执行
   // main_phase是UVM运行时的一个阶段，用于执行主要的测试逻辑
   extern virtual task main_phase(uvm_phase phase);
endclass

// 实现my_driver类的main_phase任务
task my_driver::main_phase(uvm_phase phase);
   // 使用UVM的`uvm_info宏打印一条信息，表示main_phase任务被调用
   `uvm_info("my_driver", "main_phase is called", UVM_LOW);

   // 初始化信号：将rxd（接收数据信号）和rx_dv（接收数据有效信号）置为0
   top_tb.rxd <= 8'b0; 
   top_tb.rx_dv <= 1'b0;

   // 等待复位信号rst_n变为高电平（即复位结束）
   // 如果rst_n为低电平，则一直等待时钟上升沿
   while(!top_tb.rst_n)
      @(posedge top_tb.clk);

   // 循环256次，每次生成一个随机数据并驱动到DUT的接口上
   for(int i = 0; i < 256; i++) begin
      // 等待时钟上升沿
      @(posedge top_tb.clk);

      // 使用$urandom_range生成一个0到255之间的随机数，并将其赋值给rxd
      top_tb.rxd <= $urandom_range(0, 255);

      // 将rx_dv信号置为1，表示当前数据有效
      top_tb.rx_dv <= 1'b1;

      // 使用UVM的`uvm_info宏打印一条信息，表示数据已经被驱动
      // "my_driver"是消息的标签，"data is drived"是消息内容，UVM_LOW是消息的详细级别
      `uvm_info("my_driver", "data is drived", UVM_LOW);
   end

   // 最后一次等待时钟上升沿
   @(posedge top_tb.clk);

   // 将rx_dv信号置为0，表示数据发送结束
   top_tb.rx_dv <= 1'b0;
endtask

// 结束宏定义
`endif
