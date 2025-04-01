// 防止文件重复包含的宏定义
// 如果MY_DRIVER__SV没有被定义过，则定义它，并编译以下代码
`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV

// 定义一个类my_driver，继承自UVM的uvm_driver类
// uvm_driver是UVM库中用于驱动DUT信号的基类
class my_driver extends uvm_driver;

   // 声明一个虚拟接口变量vif，类型为my_if
   // 虚拟接口用于与DUT的物理接口通信
   virtual my_if vif;

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

   // 定义build_phase函数，用于构建阶段的操作
   // build_phase是UVM的一个阶段，用于组件的初始化和配置
   virtual function void build_phase(uvm_phase phase);
      // 调用父类的build_phase函数
      super.build_phase(phase);

      // 使用UVM的`uvm_info宏打印一条信息，表示build_phase函数被调用
      `uvm_info("my_driver", "build_phase is called", UVM_LOW);

      // 从UVM配置数据库（uvm_config_db）中获取虚拟接口vif
      // 如果获取失败，则调用`uvm_fatal终止仿真
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
         `uvm_fatal("my_driver", "virtual interface must be set for vif!!!")
   endfunction

   // 声明一个外部的任务main_phase，该任务将在UVM的main_phase阶段执行
   // main_phase是UVM运行时的一个阶段，用于执行主要的测试逻辑
   extern virtual task main_phase(uvm_phase phase);
endclass

// 实现my_driver类的main_phase任务
task my_driver::main_phase(uvm_phase phase);
   // 调用phase.raise_objection(this)，表示开始执行main_phase任务
   // 防止UVM提前结束仿真
   phase.raise_objection(this);

   // 使用UVM的`uvm_info宏打印一条信息，表示main_phase任务被调用
   `uvm_info("my_driver", "main_phase is called", UVM_LOW);

   // 初始化信号：将data（数据信号）和valid（数据有效信号）置为0
   vif.data <= 8'b0; 
   vif.valid <= 1'b0;

   // 等待复位信号rst_n变为高电平（即复位结束）
   // 如果rst_n为低电平，则一直等待时钟上升沿
   while(!vif.rst_n)
      @(posedge vif.clk);

   // 循环256次，每次生成一个随机数据并驱动到DUT的接口上
   for(int i = 0; i < 256; i++) begin
      // 等待时钟上升沿
      @(posedge vif.clk);

      // 使用$urandom_range生成一个0到255之间的随机数，并将其赋值给data
      vif.data <= $urandom_range(0, 255);

      // 将valid信号置为1，表示当前数据有效
      vif.valid <= 1'b1;

      // 使用UVM的`uvm_info宏打印一条信息，表示数据已经被驱动
      // "my_driver"是消息的标签，"data is drived"是消息内容，UVM_LOW是消息的详细级别
      `uvm_info("my_driver", "data is drived", UVM_LOW);
   end

   // 最后一次等待时钟上升沿
   @(posedge vif.clk);

   // 将valid信号置为0，表示数据发送结束
   vif.valid <= 1'b0;

   // 调用phase.drop_objection(this)，表示main_phase任务执行结束
   // 允许UVM结束仿真
   phase.drop_objection(this);
endtask

// 结束宏定义
`endif
