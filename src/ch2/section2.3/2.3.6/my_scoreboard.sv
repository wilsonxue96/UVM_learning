`ifndef MY_SCOREBOARD__SV
`define MY_SCOREBOARD__SV

// 定义一个名为 my_scoreboard 的类，继承自 uvm_scoreboard。
// uvm_scoreboard 是 UVM 框架中用于实现评分板功能的基类，用于比较预期事务和实际事务。
class my_scoreboard extends uvm_scoreboard;
   // 定义一个队列，用于存储预期事务。
   my_transaction  expect_queue[$];

   // 定义两个阻塞式获取端口，分别用于接收预期事务和实际事务。
   uvm_blocking_get_port #(my_transaction)  exp_port;
   uvm_blocking_get_port #(my_transaction)  act_port;

   // 使用 UVM 宏 `uvm_component_utils 注册该类，以便 UVM 框架能够识别和管理该类。
   // 这个宏会为类提供一些默认的方法，如打印、比较等。
   `uvm_component_utils(my_scoreboard)

   // 声明构造函数、build_phase 方法和 main_phase 任务，具体实现将在类外部定义。
   extern function new(string name, uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);
endclass 

// 构造函数的实现。
// 用于创建 my_scoreboard 类的实例。
function my_scoreboard::new(string name, uvm_component parent = null);
   super.new(name, parent); // 调用父类的构造函数完成初始化
endfunction 

// build_phase 方法的实现。
// 在 UVM 的验证流程中，build_phase 是组件初始化的阶段。
function void my_scoreboard::build_phase(uvm_phase phase);
   super.build_phase(phase); // 调用父类的 build_phase 方法
   // 创建两个阻塞式获取端口的实例。
   exp_port = new("exp_port", this); // 创建接收预期事务的端口
   act_port = new("act_port", this); // 创建接收实际事务的端口
endfunction 

// main_phase 任务的实现。
// 在 UVM 的验证流程中，main_phase 是组件的主要活动阶段。
task my_scoreboard::main_phase(uvm_phase phase);
   my_transaction  get_expect,  get_actual, tmp_tran; // 定义事务变量
   bit result; // 定义比较结果变量

   super.main_phase(phase); // 调用父类的 main_phase 方法
   // 启动两个并行的进程，分别处理预期事务和实际事务。
   fork 
      // 处理预期事务的进程。
      while (1) begin
         exp_port.get(get_expect); // 从预期端口接收事务
         expect_queue.push_back(get_expect); // 将接收到的事务存储到队列中
      end
      // 处理实际事务的进程。
      while (1) begin
         act_port.get(get_actual); // 从实际端口接收事务
         // 检查预期队列是否为空。
         if(expect_queue.size() > 0) begin
            tmp_tran = expect_queue.pop_front(); // 从队列中取出一个预期事务
            result = get_actual.my_compare(tmp_tran); // 比较实际事务和预期事务
            // 根据比较结果打印信息。
            if(result) begin 
               `uvm_info("my_scoreboard", "Compare SUCCESSFULLY", UVM_LOW);
            end
            else begin
               `uvm_error("my_scoreboard", "Compare FAILED");
               $display("the expect pkt is");
               tmp_tran.my_print(); // 打印预期事务
               $display("the actual pkt is");
               get_actual.my_print(); // 打印实际事务
            end
         end
         else begin
            // 如果预期队列为空，但接收到实际事务，打印错误信息。
            `uvm_error("my_scoreboard", "Received from DUT, while Expect Queue is empty");
            $display("the unexpected pkt is");
            get_actual.my_print(); // 打印意外接收到的事务
         end 
      end
   join // 等待两个进程结束
endtask

`endif // MY_SCOREBOARD__SV
