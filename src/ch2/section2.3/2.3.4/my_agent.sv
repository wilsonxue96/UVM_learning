`ifndef MY_AGENT__SV
`define MY_AGENT__SV

// 定义一个名为 my_agent 的类，继承自 uvm_agent。
// uvm_agent 是 UVM 框架中用于表示验证代理（agent）的基类。
// 代理通常包含驱动器（driver）、监视器（monitor）和序列器（sequencer）等组件。
class my_agent extends uvm_agent;
   // 定义一个 my_driver 类型的成员变量 drv，用于存储驱动器对象。
   my_driver     drv;
   // 定义一个 my_monitor 类型的成员变量 mon，用于存储监视器对象。
   my_monitor    mon;

   // 构造函数，用于创建 my_agent 类的实例。
   // name 是实例的名称，parent 是父组件。
   function new(string name, uvm_component parent);
      super.new(name, parent); // 调用父类的构造函数完成初始化
   endfunction

   // 声明两个外部方法，具体实现将在类外部定义。
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

   // 使用 UVM 宏 `uvm_component_utils 注册该类，以便 UVM 框架能够识别和管理该类。
   // 这个宏会为类提供一些默认的方法，如打印、比较等。
   `uvm_component_utils(my_agent)
endclass

// 定义 build_phase 方法，这是 UVM 验证流程中的一个阶段。
// 在这个阶段，组件可以进行一些初始化操作，如创建子组件等。
function void my_agent::build_phase(uvm_phase phase);
   super.build_phase(phase); // 调用父类的 build_phase 方法
   // 检查代理是否处于主动模式（UVM_ACTIVE）。
   // 如果是主动模式，则创建驱动器对象。
   if (is_active == UVM_ACTIVE) begin
       drv = my_driver::type_id::create("drv", this); // 使用 UVM 工厂机制创建驱动器对象
   end
   // 创建监视器对象。
   mon = my_monitor::type_id::create("mon", this); // 使用 UVM 工厂机制创建监视器对象
endfunction

// 定义 connect_phase 方法，这是 UVM 验证流程中的一个阶段。
// 在这个阶段，组件可以进行连接操作，如连接驱动器和监视器的端口等。
function void my_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase); // 调用父类的 connect_phase 方法
   // 在这个例子中，没有具体的连接操作，因此该方法为空。
endfunction

`endif // MY_AGENT__SV
