
`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

// 定义一个名为 my_transaction 的类，继承自 uvm_sequence_item。
// uvm_sequence_item 是 UVM 中用于表示事务（transaction）的基类。
// 继承该类可以利用 UVM 提供的事务处理功能，如随机化等。
class my_transaction extends uvm_sequence_item;

   // 随机变量，表示目的 MAC 地址，48 位宽。
   rand bit[47:0] dmac;
   // 随机变量，表示源 MAC 地址，48 位宽。
   rand bit[47:0] smac;
   // 随机变量，表示以太网类型字段，16 位宽。
   rand bit[15:0] ether_type;
   // 随机变量，表示负载数据，是一个字节数组，长度可变。
   rand byte      pload[];
   // 随机变量，表示循环冗余校验码，32 位宽。
   rand bit[31:0] crc;

   // 定义约束条件，限制负载数据（pload）的大小。
   // 以太网帧的负载大小通常在 46 到 1500 字节之间。
   constraint pload_cons{
      pload.size >= 46; // 最小负载大小为 46 字节
      pload.size <= 1500; // 最大负载大小为 1500 字节
   }

   // 定义一个函数用于计算 CRC 校验码。
   // 这里只是一个占位函数，返回固定的值 0。
   // 在实际应用中，需要实现真实的 CRC 计算逻辑。
   function bit[31:0] calc_crc();
      return 32'h0; // 返回固定的 32 位值 0
   endfunction

   // 定义一个回调函数，用于在随机化完成后执行。
   // post_randomize 是 UVM 提供的一个回调函数，用于在随机化完成后进行一些额外的操作。
   // 在这里，它被用来更新 crc 字段的值，调用 calc_crc 函数计算 CRC 校验码。
   function void post_randomize();
      crc = calc_crc(); // 调用 calc_crc 函数计算 CRC 并赋值给 crc 变量
   endfunction

   // 使用 UVM 宏 `uvm_object_utils 注册类，以便 UVM 框架能够识别和管理该类。
   // 这个宏会为类提供一些默认的方法，如打印、比较等。
   `uvm_object_utils(my_transaction)

   // 构造函数，用于创建 my_transaction 类的实例。
   // name 是实例的名称，默认值为 "my_transaction"。
   // 调用父类的构造函数 super.new() 完成初始化。
   function new(string name = "my_transaction");
      super.new(name); // 调用父类的构造函数
   endfunction
endclass

`endif // MY_TRANSACTION__SV
