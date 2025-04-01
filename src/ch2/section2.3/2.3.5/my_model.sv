`ifndef MY_MODEL__SV
`define MY_MODEL__SV

// 定义一个名为 my_model 的类，继承自 uvm_component。
// uvm_component 是 UVM 框架中所有组件的基类，提供了基本的组件功能。
class my_model extends uvm_component;

   // 定义一个阻塞式获取端口（uvm_blocking_get_port），用于从其他组件接收事务。
   // 参数类型为 my_transaction，表示该端口接收的数据类型。
   uvm_blocking_get_port #(my_transaction)  port;

   // 定义一个分析端口（uvm_analysis_port），用于将事务发送到其他组件。
   // 参数类型为 my_transaction，表示该端口发送的数据类型。
   uvm_analysis_port #(my_transaction)  ap;

   // 声明构造函数、build_phase 方法和 main_phase 任务，具体实现将在类外部定义。
   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);

   // 使用 UVM 宏 `uvm_component_utils 注册该类，以便 UVM 框架能够识别和管理该类。
   // 这个宏会为类提供一些默认的方法，如打印、比较等。
   `uvm_component_utils(my_model)
endclass 

// 构造函数的实现。
// 用于创建 my_model 类的实例。
function my_model::new(string name, uvm_component parent);
   super.new(name, parent); // 调用父类的构造函数完成初始化
endfunction 

// build_phase 方法的实现。
// 在 UVM 的验证流程中，build_phase 是用于组件初始化的阶段。
function void my_model::build_phase(uvm_phase phase);
   super.build_phase(phase); // 调用父类的 build_phase 方法
   // 创建阻塞式获取端口和分析端口的实例。
   port = new("port", this); // 创建阻塞式获取端口实例
   ap = new("ap", this);     // 创建分析端口实例
endfunction

// main_phase 任务的实现。
// 在 UVM 的验证流程中，main_phase 是组件的主要活动阶段。
task my_model::main_phase(uvm_phase phase);
   my_transaction tr;     // 创建一个 my_transaction 类型的事务对象
   my_transaction new_tr; // 创建另一个 my_transaction 类型的事务对象
   super.main_phase(phase); // 调用父类的 main_phase 方法

   // 无限循环，持续接收事务并处理。
   while(1) begin
      // 从阻塞式获取端口接收一个事务。
      port.get(tr); // 阻塞式调用，直到接收到一个事务
      // 创建一个新的事务对象并复制接收到的事务内容。
      new_tr = new("new_tr"); // 创建一个新的事务对象
      new_tr.my_copy(tr);     // 调用自定义的 my_copy 方法复制事务内容
      // 打印信息，表示接收到一个事务并进行了复制。
      `uvm_info("my_model", "get one transaction, copy and print it:", UVM_LOW)
      // 打印复制后的事务内容。
      new_tr.my_print(); // 调用自定义的 my_print 方法打印事务内容
      // 将复制后的事务发送到分析端口。
      ap.write(new_tr); // 将事务发送到分析端口
   end
endtask

`endif // MY_MODEL__SV
