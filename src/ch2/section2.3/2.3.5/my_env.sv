`ifndef MY_ENV__SV
`define MY_ENV__SV

// 定义一个名为 my_env 的类，继承自 uvm_env。
// uvm_env 是 UVM 框架中用于表示验证环境的基类，通常包含多个验证组件（如代理、模型等）。
class my_env extends uvm_env;

   // 定义两个 my_agent 类型的成员变量 i_agt 和 o_agt，分别表示输入代理和输出代理。
   my_agent  i_agt;
   my_agent  o_agt;
   // 定义一个 my_model 类型的成员变量 mdl，表示模型组件。
   my_model  mdl;

   // 定义一个 UVM 事务级建模（TLM）分析 FIFO，用于在代理和模型之间传递事务。
   // 参数类型为 my_transaction，表示 FIFO 中存储的数据类型。
   uvm_tlm_analysis_fifo #(my_transaction) agt_mdl_fifo;

   // 构造函数，用于创建 my_env 类的实例。
   // name 是实例的名称，默认值为 "my_env"。
   // parent 是父组件，默认值为 null。
   function new(string name = "my_env", uvm_component parent);
      super.new(name, parent); // 调用父类的构造函数完成初始化
   endfunction

   // 定义 build_phase 方法，这是 UVM 验证流程中的一个阶段。
   // 在这个阶段，组件可以进行一些初始化操作，如创建子组件等。
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); // 调用父类的 build_phase 方法
      // 使用 UVM 工厂机制创建输入代理（i_agt）和输出代理（o_agt）。
      i_agt = my_agent::type_id::create("i_agt", this);
      o_agt = my_agent::type_id::create("o_agt", this);
      // 设置输入代理为主动模式（UVM_ACTIVE），输出代理为被动模式（UVM_PASSIVE）。
      i_agt.is_active = UVM_ACTIVE;
      o_agt.is_active = UVM_PASSIVE;
      // 使用 UVM 工厂机制创建模型组件（mdl）。
      mdl = my_model::type_id::create("mdl", this);
      // 创建一个 TLM 分析 FIFO 实例。
      agt_mdl_fifo = new("agt_mdl_fifo", this);
   endfunction

   // 声明 connect_phase 方法，具体实现将在类外部定义。
   extern virtual function void connect_phase(uvm_phase phase);

   // 使用 UVM 宏 `uvm_component_utils 注册该类，以便 UVM 框架能够识别和管理该类。
   // 这个宏会为类提供一些默认的方法，如打印、比较等。
   `uvm_component_utils(my_env)
endclass

// 定义 connect_phase 方法，这是 UVM 验证流程中的一个阶段。
// 在这个阶段，组件可以进行连接操作，如连接端口、FIFO 等。
function void my_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase); // 调用父类的 connect_phase 方法
   // 将输入代理的分析端口（ap）连接到 TLM 分析 FIFO 的分析导出端口（analysis_export）。
   i_agt.ap.connect(agt_mdl_fifo.analysis_export);
   // 将模型的阻塞式获取端口（port）连接到 TLM 分析 FIFO 的阻塞式获取导出端口（blocking_get_export）。
   mdl.port.connect(agt_mdl_fifo.blocking_get_export);
endfunction

`endif // MY_ENV__SV
