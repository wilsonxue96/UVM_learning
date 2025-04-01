`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV

// 定义一个名为 my_driver 的类，继承自 uvm_driver。
// uvm_driver 是 UVM 框架中用于实现驱动器功能的基类。
class my_driver extends uvm_driver;

   // 定义一个虚拟接口 vif，用于与测试平台中的接口连接。
   // 虚拟接口允许驱动器通过接口与 DUT（被验证设计）交互。
   virtual my_if vif;

   // 使用 UVM 宏 `uvm_component_utils 注册该类，以便 UVM 框架能够识别和管理该类。
   // 这个宏会为类提供一些默认的方法，如打印、比较等。
   `uvm_component_utils(my_driver)

   // 构造函数，用于创建 my_driver 类的实例。
   // name 是实例的名称，默认值为 "my_driver"。
   // parent 是父组件，默认值为 null。
   function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent); // 调用父类的构造函数完成初始化
   endfunction

   // 定义 build_phase 方法，这是 UVM 验证流程中的一个阶段。
   // 在这个阶段，组件可以进行一些初始化操作。
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); // 调用父类的 build_phase 方法
      // 从配置数据库中获取虚拟接口 vif。
      // 如果获取失败，打印错误信息并终止验证。
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
         `uvm_fatal("my_driver", "virtual interface must be set for vif!!!")
   endfunction

   // 声明两个外部任务，具体实现将在类外部定义。
   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(my_transaction tr);
endclass

// 定义 main_phase 任务，这是驱动器的主要任务，负责驱动数据到 DUT。
task my_driver::main_phase(uvm_phase phase);
   my_transaction tr; // 创建一个 my_transaction 类型的事务对象
   phase.raise_objection(this); // 提出异议，表示驱动器开始工作
   vif.data <= 8'b0; // 初始化数据信号为 0
   vif.valid <= 1'b0; // 初始化有效信号为 0
   // 等待复位信号释放（rst_n 变为高电平）。
   while(!vif.rst_n)
      @(posedge vif.clk);
   // 循环两次，生成两个事务。
   for(int i = 0; i < 2; i++) begin 
      tr = new("tr"); // 创建一个新的事务对象
      // 随机化事务对象，同时约束负载大小为 200 字节。
      assert(tr.randomize() with {pload.size == 200;});
      drive_one_pkt(tr); // 调用 drive_one_pkt 任务驱动一个事务
   end
   // 等待 5 个时钟周期。
   repeat(5) @(posedge vif.clk);
   phase.drop_objection(this); // 撤销异议，表示驱动器工作完成
endtask

// 定义 drive_one_pkt 任务，负责驱动一个事务到 DUT。
task my_driver::drive_one_pkt(my_transaction tr);
   bit [47:0] tmp_data; // 临时变量，用于处理数据
   bit [7:0] data_q[$]; // 定义一个队列，用于存储要驱动的数据

   // 将目的 MAC 地址（dmac）分解为字节并加入队列。
   tmp_data = tr.dmac;
   for(int i = 0; i < 6; i++) begin
      data_q.push_back(tmp_data[7:0]); // 将低 8 位加入队列
      tmp_data = (tmp_data >> 8); // 右移 8 位
   end
   // 将源 MAC 地址（smac）分解为字节并加入队列。
   tmp_data = tr.smac;
   for(int i = 0; i < 6; i++) begin
      data_q.push_back(tmp_data[7:0]);
      tmp_data = (tmp_data >> 8);
   end
   // 将以太网类型字段（ether_type）分解为字节并加入队列。
   tmp_data = tr.ether_type;
   for(int i = 0; i < 2; i++) begin
      data_q.push_back(tmp_data[7:0]);
      tmp_data = (tmp_data >> 8);
   end
   // 将负载数据（pload）加入队列。
   for(int i = 0; i < tr.pload.size; i++) begin
      data_q.push_back(tr.pload[i]);
   end
   // 将循环冗余校验码（crc）分解为字节并加入队列。
   tmp_data = tr.crc;
   for(int i = 0; i < 4; i++) begin
      data_q.push_back(tmp_data[7:0]);
      tmp_data = (tmp_data >> 8);
   end

   // 打印信息，表示开始驱动一个数据包。
   `uvm_info("my_driver", "begin to drive one pkt", UVM_LOW);
   // 等待 3 个时钟周期。
   repeat(3) @(posedge vif.clk);

   // 从队列中逐个取出数据并驱动到 DUT。
   while(data_q.size() > 0) begin
      @(posedge vif.clk); // 等待时钟上升沿
      vif.valid <= 1'b1; // 设置有效信号为高
      vif.data <= data_q.pop_front(); // 驱动数据到 DUT
   end

   // 等待一个时钟周期后，将有效信号置为低。
   @(posedge vif.clk);
   vif.valid <= 1'b0;
   // 打印信息，表示结束驱动一个数据包。
   `uvm_info("my_driver", "end drive one pkt", UVM_LOW);
endtask

`endif
