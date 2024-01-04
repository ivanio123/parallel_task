with Ada.Containers;
with Ada.Containers.Vectors;
with Ada.Real_Time; use Ada.Real_Time;

with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   package Integer_Vectors is new Ada.Containers.Vectors (Index_Type => Natural, Element_Type => Long_Long_Integer);
   use Integer_Vectors;

   protected type Protected_Integer_Vector is

      procedure Append(Element : Long_Long_Integer);
      procedure PutLine;
      procedure Set(newVec : Integer_Vectors.Vector);
      function Length return Natural;
      function Element(Index : Natural) return Long_Long_Integer;
      function First_Element return Long_Long_Integer;
      function Last_Element return Long_Long_Integer;
      function Get_Elements return Integer_Vectors.Vector;
      procedure Clear;
      procedure Delete_First;
      procedure Delete_Last;

   private
      vec : Integer_Vectors.Vector;

   end Protected_Integer_Vector;


   protected body Protected_Integer_Vector is

      procedure Append(Element : Long_Long_Integer) is
      begin
         vec.Append(Element);
      end Append;

      function Get_Elements return Integer_Vectors.Vector is
      begin
         return vec;
      end Get_Elements;

      procedure PutLine is
      begin
         for Element of vec loop
            Put(Element'Img & " ");
         end loop;
      end PutLine;

      procedure Delete_First is
      begin
         if Natural(vec.Length) > 1 then
            vec.Delete_First;
         end if;
      end Delete_First;

      procedure Delete_Last is
      begin
           if Natural(vec.Length) > 1 then
            vec.Delete_Last;
            end if;
       end Delete_Last;

      procedure Set(newVec : Integer_Vectors.Vector) is
      begin
         vec := newVec;
      end Set;

      function Length return Natural is
      begin
         return Natural(vec.Length);
      end Length;

      function First_Element return Long_Long_Integer is
      begin
         return vec.First_Element;
      end First_Element;

      function Last_Element return Long_Long_Integer is
      begin
         return vec.Last_Element;
      end Last_Element;

      function Element(Index : Natural) return Long_Long_Integer is
      begin
         return vec.Element(Index);
      end Element;

      procedure Clear is
      begin
         vec.Clear;
      end Clear;
   end Protected_Integer_Vector;

   vector : Protected_Integer_Vector;
   resultVector : Protected_Integer_Vector;
   nextLength : Long_Long_Integer;
   sum : Long_Long_Integer;
   Elapsed_Time : Time_Span;
   Start_Time, End_Time : Time;
   Elapsed_Time_Ms : Duration;
   ms    : Duration := 1000.0;

   task type Parallel_Task is
      entry Start;
   end Parallel_Task;

   task body Parallel_Task is
   begin

      accept Start do

      nextLength := (Integer(vector.Length) + 1) / 2;

      for I in 1 .. nextLength loop
          if vector.Length = 1 then
            resultVector.Append(vector.First_Element);
            vector.Delete_First;
          else
             sum := vector.First_Element + vector.Last_Element;
             resultVector.Append(sum);
             vector.Delete_First;
             vector.Delete_Last;
            end if;
       end loop;
       vector.Set(resultVector.Get_Elements);
       resultVector.Clear;
       Put ("vec length: " & Integer'Image (vector.Length));
       Put_Line (Integer_Vectors.Vector'Image (vector.Get_Elements));
            end Start;


   end Parallel_Task;

   task1 : Parallel_Task;
   task2 : Parallel_Task;
   task3 : Parallel_Task;
   task4 : Parallel_Task;
   task5 : Parallel_Task;
   task6 : Parallel_Task;

begin

   for I in 1 .. 30 loop
        vector.Append (I);
   end loop;
   Put ("vec length: " & Integer'Image (vector.Length));
   Put_Line (Integer_Vectors.Vector'Image (vector.Get_Elements));

   Start_Time := Ada.Real_Time.Clock;

   task1.Start;
   task2.Start;
   task3.Start;
   task4.Start;
   task5.Start;
   task6.Start;

   End_Time := Ada.Real_Time.Clock;

   Elapsed_Time := End_Time - Start_Time;
   Elapsed_Time_Ms := To_Duration(Elapsed_Time) * ms;

   Put_Line("Your result: " & Integer_Vectors.Vector'Image (vector.Get_Elements));
   Put ("Elapsed Time (ms): ");
   Put(Duration'Image(Elapsed_Time_Ms));
   null;
end Main;
