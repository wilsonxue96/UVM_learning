`ifndef MY_ENV__SV
`define MY_ENV__SV

// 定义一个名为 my_env 的类，继承自 uvm_env。
// uvm_env 是 UVM 框架中用于表示验证环境的基类，通常包含多个验证组件（如驱动器、监视器等）。
class my_env extends uvm_env;

   // 定义一个 my_driver 类型的成员变量 drv，用于存储驱动器对象。
   my_driver drv;

   // 构造函数，用于创建 my_env 类的实例。
   // name 是实例的名称，默认值为 "my_env"。
   // parent 是父组件，表示当前组件所属的父组件。
   function new(string name = "my_env", uvm_component parent);
      super.new(name, parent); // 调用父类的构造函数完成初始化
   endfunction

   // 定义 build_phase 方法，这是 UVM 验证流程中的一个阶段。
   // 在这个阶段，组件可以进行一些初始化操作，如创建子组件等。
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); // 调用父类的 build_phase 方法
      // 使用 UVM 的工厂机制创建 my_driver 类型的驱动器对象。
      // "drv" 是驱动器对象的名称，this 表示当前环境对象是驱动器的父组件。
      drv = my_driver::type_id::create("drv", this); 
   endfunction

   // 使用 UVM 宏 `uvm_component_utils 注册该类，以便 UVM 框架能够识别和管理该类。
   // 这个宏会为类提供一些默认的方法，如打印、比较等。
   `uvm_component_utils(my_env)
endclass

`endif // MY_ENV__SV
