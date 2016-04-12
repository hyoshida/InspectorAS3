import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.ui.MouseCursor;

import mx.controls.Label;
import mx.core.UIComponent;

import spark.components.HGroup;
import spark.components.RichEditableText;
import spark.components.VGroup;
import spark.events.TextOperationEvent;
import spark.skins.spark.FocusSkin;

public class InspectorAS3 extends UIComponent {
  public static const WIDTH:int = 200;
  public static const HEIGHT:int = 300;
  public static const PADDING:int = 10;
  public static const LINE_HEIGHT:int = 12;

  private static var instance:InspectorAS3;

  private var _container:VGroup;
  private var _nameInputField:RichEditableText;
  private var _xInputField:RichEditableText;
  private var _yInputField:RichEditableText;
  private var _widthInputField:RichEditableText;
  private var _heightInputField:RichEditableText;
  private var _previousMouseX:int;
  private var _previousMouseY:int;
  private var _spinnableTarget:DisplayObject;
  private var _spinnableMouseX:int;
  private var _spinnableMouseY:int;
  private var _shiftKey:Boolean;
  private var _target:DisplayObject;
  private var _border:Sprite;

  public static function create(parent:DisplayObjectContainer):void {
    if (instance) {
      return;
    }
    instance = new InspectorAS3;
    parent.addChild(instance);
  }

  public static function destroy():void {
    if (!instance) {
      return;
    }
    instance.parent.removeChild(instance);
    instance.dispose();
    instance = null;
  }

  private function get shiftKey():Boolean {
    return _shiftKey;
  }

  private function set shiftKey(value:Boolean):void {
    _shiftKey = value;
    Mouse.cursor = _shiftKey ? MouseCursor.HAND : MouseCursor.AUTO;
  }

  private function get target():DisplayObject {
    return _target;
  }

  private function set target(value:DisplayObject):void {
    if (value == _border) {
      value = null;
    }

    clearTargetBorder();
    _target = value;
    drawTargetBorder();

    refresh();

    if (_target) {
      _target.addEventListener(Event.REMOVED_FROM_STAGE, function(event:Event):void {
        removeEventListener(Event.REMOVED_FROM_STAGE, arguments.callee);
        target = null;
      });
    }
  }

  public function InspectorAS3() {
    super();

    initializeProperties();
    createBackground();
    createContainer();
    createNameInputField();
    createPositionGroup();
    createSizeGroup();

    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
  }

  public function dispose():void {
    removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
  }

  public function refresh():void {
    var targetOrObject:Object = target || {};
    _nameInputField.text = targetOrObject.name;
    _xInputField.text = targetOrObject.x;
    _yInputField.text = targetOrObject.y;
    _widthInputField.text = targetOrObject.width;
    _heightInputField.text = targetOrObject.height;
    refreshBorder();
  }

  public function refreshFromInput():void {
    if (!target) {
      return;
    }
    target.name = _nameInputField.text;
    target.x = Number(_xInputField.text);
    target.y = Number(_yInputField.text);
    target.width = Number(_widthInputField.text);
    target.height = Number(_heightInputField.text);
    refreshBorder();
  }

  private function initializeProperties():void {
    width = WIDTH;
    height = HEIGHT;
  }

  private function createBackground():void {
    graphics.lineStyle(1, 0xaaaaaa);
    graphics.beginFill(0xcccccc);
    graphics.drawRect(0, 0, width, height);
    graphics.endFill();
  }

  private function createContainer():void {
    var container:VGroup = new VGroup;
    container.width = width;
    container.height = height;
    container.padding = PADDING;
    addChild(container);

    _container = container;
  }

  private function createNameInputField():void {
    var inputField:RichEditableText = buildInputField();
    inputField.width = width - (PADDING * 2);
    inputField.height = LINE_HEIGHT;
    _container.addElement(inputField);

    _nameInputField = inputField;
  }

  private function createPositionGroup():void {
    var group:HGroup = new HGroup;
    group.width = width - (PADDING * 2);
    group.height = LINE_HEIGHT;
    _container.addElement(group);

    var xInputField:RichEditableText = buildInputField();
    var xLabel:Label = buildSpinnableLabel(xInputField);
    xLabel.text = "x:";
    xLabel.percentWidth = 25;
    xLabel.percentHeight = 100;
    group.addElement(xLabel);

    xInputField.percentWidth = 25;
    xInputField.percentHeight = 100;
    group.addElement(xInputField);

    _xInputField = xInputField;

    var yInputField:RichEditableText = buildInputField();
    var yLabel:Label = buildSpinnableLabel(yInputField);
    yLabel.text = "y:";
    yLabel.percentWidth = 25;
    yLabel.percentHeight = 100;
    group.addElement(yLabel);

    yInputField.percentWidth = 25;
    yInputField.percentHeight = 100;
    group.addElement(yInputField);

    _yInputField = yInputField;
  }

  private function createSizeGroup():void {
    var group:HGroup = new HGroup;
    group.width = width - (PADDING * 2);
    group.height = LINE_HEIGHT;
    _container.addElement(group);

    var widthInputField:RichEditableText = buildInputField();
    var widthLabel:Label = buildSpinnableLabel(widthInputField);
    widthLabel.text = "width:";
    widthLabel.percentWidth = 25;
    widthLabel.percentHeight = 100;
    group.addElement(widthLabel);

    widthInputField.percentWidth = 25;
    widthInputField.percentHeight = 100;
    group.addElement(widthInputField);

    _widthInputField = widthInputField;

    var heightInputField:RichEditableText = buildInputField();
    var heightLabel:Label = buildSpinnableLabel(heightInputField);
    heightLabel.text = "height:";
    heightLabel.percentWidth = 25;
    heightLabel.percentHeight = 100;
    group.addElement(heightLabel);

    heightInputField.percentWidth = 25;
    heightInputField.percentHeight = 100;
    group.addElement(heightInputField);

    _heightInputField = heightInputField;
  }

  private function drawTargetBorder():void {
    if (!target || _border) {
      return;
    }

    _border = new Sprite;
    parent.addChild(_border);

    refreshBorder();
  }

  private function clearTargetBorder():void {
    if (!target || !_border) {
      return;
    }
    parent.removeChild(_border);
    _border = null;
  }

  private function refreshBorder():void {
    if (!target || !_border) {
      return;
    }

    var position:Point = target.localToGlobal(new Point);
    _border.x = position.x;
    _border.y = position.y;

    var thickness:int = 2;
    var width:Number = target.width;
    var height:Number = target.height;
    _border.graphics.clear();
    _border.graphics.lineStyle(thickness, 0x0095ff);
    _border.graphics.beginFill(0x000000, 0)
    _border.graphics.drawRect(0, 0, width, height);
    _border.graphics.endFill();

    var pointSize:int = 5;
    _border.graphics.beginFill(0x0095ff);
    // top-left
    _border.graphics.drawRect(-pointSize * 0.5, -pointSize * 0.5, pointSize, pointSize);
    // top-right
    _border.graphics.drawRect(width - pointSize * 0.5, -pointSize * 0.5, pointSize, pointSize);
    // bottom-left
    _border.graphics.drawRect(-pointSize * 0.5, height - pointSize * 0.5, pointSize, pointSize);
    // bottom-right
    _border.graphics.drawRect(width - pointSize * 0.5, height - pointSize * 0.5, pointSize, pointSize);
    _border.graphics.endFill();
  }

  private function resizeTargetBorder():void {
    clearTargetBorder();
    drawTargetBorder();
  }

  private function buildSpinnableLabel(inputField:RichEditableText):Label {
    var label:Label = new Label;
    var priority:int = 100;

    label.addEventListener(Event.ADDED_TO_STAGE, function(_event:Event):void {
      label.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
        _spinnableTarget = event.target as DisplayObject;
        _spinnableMouseX = stage.mouseX;
      }, true, priority);

      stage.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void {
        if (!_spinnableTarget || (_spinnableTarget != label && _spinnableTarget.parent != label)) {
          return;
        }

        event.stopImmediatePropagation();

        _spinnableTarget = null;
      }, true, priority);

      stage.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
        if (!_spinnableTarget || (_spinnableTarget != label && _spinnableTarget.parent != label)) {
          return;
        }

        event.stopImmediatePropagation();

        var movementX:Number = stage.mouseX - _spinnableMouseX;
        inputField.text = (Number(inputField.text) + movementX).toString();
        _spinnableMouseX = stage.mouseX;

        refreshFromInput();
      }, true, priority);
    });

    return label;
  }

  private function buildInputField():RichEditableText {
    var inputField:RichEditableText = new RichEditableText;
    inputField.multiline = false;
    inputField.setStyle("color", 0x000000);
    inputField.setStyle("backgroundAlpha", 1);
    inputField.setStyle("backgroundColor", 0xffffff);
    inputField.setStyle("focusSkin", FocusSkin);

    inputField.addEventListener(TextOperationEvent.CHANGE, function(_event:Event):void {
      refreshFromInput();
    });

    return inputField;
  }

  private function onAddedToStage(_event:Event):void {
    stage.addEventListener(Event.ADDED, onAdded);
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownStage);
    stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpStage);
    stage.addEventListener(MouseEvent.CLICK, onClickStage, true);
    stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage, true);
    stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveStage, true);
  }

  private function onRemovedFromStage(_event:Event):void {
    stage.removeEventListener(Event.ADDED, onAdded);
    stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownStage);
    stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUpStage);
    stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage, true);
    stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveStage, true);
  }

  private function onAdded(event:Event):void {
    // InspectorAS3 Always-on-Top
    if (event.target.parent == parent) {
      parent.setChildIndex(this, parent.numChildren - 1);

      if (_border) {
        parent.setChildIndex(_border, parent.numChildren - 1);
      }
    }
  }

  private function onKeyDownStage(event:KeyboardEvent):void {
    shiftKey = event.shiftKey;
  }

  private function onKeyUpStage(event:KeyboardEvent):void {
    shiftKey = false;

    const VK_TAB:int = 9;
    const VK_ESC:int = 27;

    switch (event.keyCode) {
      case VK_TAB:
        target = target ? target.parent : null;
        break;
      case VK_ESC:
        target = null;
        break
    }
  }

  private function onClickStage(event:MouseEvent):void {
    if (!shiftKey) {
      return;
    }

    event.stopImmediatePropagation();

    var objects:Array = MovieClip(root).getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
    if (objects.length > 0) {
      target = objects[objects.length - 1] as DisplayObject;
    } else {
      target = null;
    }
  }

  private function onMouseDownStage(_event:MouseEvent):void {
    _previousMouseX = stage.mouseX;
    _previousMouseY = stage.mouseY;
  }

  private function onMouseMoveStage(event:MouseEvent):void {
    if (!event.buttonDown || !target) {
      return;
    }

    event.stopImmediatePropagation();

    var movementX:Number = stage.mouseX - _previousMouseX;
    var movementY:Number = stage.mouseY - _previousMouseY;
    target.x += movementX;
    target.y += movementY;
    _previousMouseX = stage.mouseX;
    _previousMouseY = stage.mouseY;

    refresh();
  }
}
