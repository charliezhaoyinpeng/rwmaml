��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2169477489280qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2171005010320qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2171005013296qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2171005009072q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2171005009648q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2171005014160q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2169477489280qX   2171005009072qX   2171005009648qX   2171005010320qX   2171005013296qX   2171005014160qe.(       �?f0E��u>� ��3�>�E=`�ܻLMX����>I꠾Z��>�G=+�s�j�?}�>���>r�>N�6�ws[��p�>�������7���d>Ŀ�;�2'?�B۽jU>���M���R��e��L��9?@h�>B�=c��̭�>�X�#�ᾗ�3�(        :ӽ�>	�g���= c�>�ɲ�f�>c��j��>,�>>�]a=�rE�J�?��y����=�i�>>������\/�@;g=%�>~B==��F�?�w�>sT�<��W=]��=´%�nfF�;�9�"�7>g4>L*@�4�H?;:m��ʏ=[�F����- q>(       �>�:<��=;�>/ှ>�!�&���a����<��7N?	���������Ý�9v?����m?y��<3�5<M�����N2C�x_P�X4�;��?��M?�.��֣�=������F�>�KI��L�	2��r񀼛�c��N:�7�9��==�v��vi�(       �䰾̃�*�;?wa?��=�n?xj=����vVѿ0V����>O��>�=?������>��>�IL��R�?�4�'��=Ɍ�>��Z��*�>l��>�]�>����s�>��2ԉ�'�|?,!����?e���>�}=�?99?S.(�[���/��=��@      �DM=`�����w�v=�����%��j�ԽR��=h";��,���˽��H���T<�3���V�mƯ9j)S�&F�6|ݽBi
�T�l��мN�u�K������;Yz�_3�<�B�=���L��30> �V��d�����&8f�D⽂jܽ�A>��"�֘�=��=�D�=,����=���=�	n���f���fd�𒐾Fx۽}�=�<���e��
{=Tˣ=T�r=qȌ���<�tC�>�����¼!伔 �=�|ݺ&G�=ڸ�;��}Z<��n�Md���*�~������ �?�\Ս���� b;o<w㵽3��1��=�%>�2��_����\>�~���ǽ���""��f?����,s�iPM��ߞ>�᤼6�%�ǀ��.�5�eB�=��`��Ġ4?+>m6��o $�/\0���	?5��>���><?������T�=ɀ<h?�Rᾥl��_佲�?ʺ?�z�=X�ɽg��>ۺ �J9/>_��>U�;�#m��y}�e���\˪>&4>to3���=<��=��N>�l�>�7�En*�H�>����<�ݽ��f��ʟ>�En��0�=D�ý��;��*������U���%��倽�^->��>H꯿/�)>HjY�fE�2�)�Ʋ��NU���/�F��0��=�=?d�T?�R�=���]~;�q�?*�:�
�>C��`���I=�V����>�)u>��=�?�M��Iӂ�1_����ݾ!]}��������j>��7>��=�9x>ӹ�F�X�m����+��VY���ƽ��Q=��>^?}�\�ؾ�=f>u�?{Y�������?�jd��S�x�������E�>���?�"��,+@�^��፾^Q5���L��׾�z��\�w?2ƒ=5J�>�1�y?G�'?>�S�����r�=F ���\����Գ�\p�rR�ܵ���>�X:="��>�Ӫ� V�tF����>�-ս�M�_f��̸�'���?����N>�$>��>P6��<�>t��r˾SIP�ċ�>#!��"����>O;>�>h�3��j*�a��@30�ӟ���n�c��4�>4�{?y�ئ�=�z6��ӽKo���z�=s��y���䲽Ƕ��|=~Ar��S��3������ ��̟��l=��ۼ0���f�<e �~�	�gH�Q�`=�#=�|ڽ�G���;L?b�����;%�X����ڼLa�� �߼n�X=��O��5��<�=Z:����;�r >��=��=7� N�>ÎX?��d?��p��Ա?�Tm?�k�~�M�O�ؽ튓?b1�>�n@�N*�z����_��\4����>�鈾��ѯc>�t�k�L�_>#�T>2�Q���Q? ��-���?�>=҄�2��>�=i��'$�&����Y=.�4����=�ix��/A$��B���]y?b8y>I�Ŀ�"�>�F¾g��~��wuB���ʿ�>?�d>�E���%@p�������s���?���ݾ��=k��>�����>�_^��6�>O�\��u߾�3����⾊�2��q�>������<?��`F?�.�`���y������f�|4սP�H?[r���A���O?߫�=c�`>�3>�D@��8�����C�><p?�1�������Gb=������B�"H=}�>���w=�۽l���>�?��<D��<�֐>ڇ<>g�U=�*�Y��O��;��.=q*�=��b>M=�=�m����=�:��8���/:�I8=���iÉ�]5�=�‾'`<�U>&%=$L:��W=�>���!^�u2�k��>�����=�O�ʇ���U���=;=)��O��j8�h�,�:�@��>߽���=|��=	�������!=dBX=-�����Ӡ=���SO�>�ep������r>����sp��5����͟��R}�Ef�>�;?Zl5=�澎f�=�#����!��w4T>n�-����<u�=!�*>'�>��3��2>l�3�������"kȽ*0h��]��ܳg>я?��9�;���54=�,ʽ&�����#�@�=���=6\��Z���b=?�ӿ�v.�m����&۽��?Ï��e����A=�=�>>K^}���� �E�l�>�[��`� =%�L?�9%>duf��>2�k��W�>�s�>U_�+?A���$��X�=���?���.3���{��|�
?�w�>�J��$Ӽ�7�N�����#H�,9���׾(�:���ɽ����z��$q>�"m>g�����Z?�#þ�����ƽ m���� ����z}�=�w]?F�����*��Օ��;ξ��]�*��h��oA�zὥ��*ם��Z�>	2�����u`	=+*��}�K��(�=*�=����Xe绰#�>u@��a��LB���U�ƍI?�W9=�q~�,XO=�_�>�нؽ�<ͬ�>����I`<L7Z���\<a@���L>B#��i���߾K�#��a�=�νq*���7x>=\��V>��΋?�5�F�l�bO>�e�&L龎t2=�K=���q��=Ve�<\�=� ˽H���D����f��;ƹ7�x��d��=&���ၽ��"=���BZ�F¯�h�=��(=Q!��Q���-W}��'5���ȡ���I�s���B��=pys=�"���=�:�+���!�������ҽ�Y�<���9�C%=Z��=}�o�=5,"�(��=b�]�Ϗ�5T��4>�#������pܽ���=�y^=��߼ow���ǽB���-���̈=����W�=��X�ܩ�j��F�=��H�1��� Q�ڃ���/ �< |�>�)Ӿ��]�3����GWe�����jKȽ񸵾{�m=���<�q?�?��>q� >��">�e?�D�m'޽7^������̶h>�:7��==ܤ�=)����=ΐ�=a6����(>��(��� m�>��=h�=�e%=�|h>//>�p����>lW�����e�6�}�=����O8�>�yV�R��=�P���jؼ��=@��="׽A�P`ļ?�b�D�E�7|d�Z�5��@=��}��$L������
���ɻJ"e=����ԽE�漥�����콦�d� =�=d�1���x=ߕB�J��B�-=|A��{~�qQ���ϼP�C�Lٷ=�xM���^=�-��'�L��`�;#���'Uy?�d>�tC�����.����>!b��O�{�Ϲ =Mg�>b�>:.���>�2	������烽k���F���x��=?3�h���a0*�����G<=/�>�ԽpC>x����9�5`s��|�B���P��u(V>�('�>A�=�?�X�8�
>,��>�@���d:����v��@m?�F�=�M�5,j=��4>��3>�׀><^���w���9�>Y]�����=��	��G�=����e�˽��0��gr��ޜ�ޜ��Z���=�*��>5L;?�XD�p�#>J�Z���]��B9��� >d��KB�>q�L̒�����JC��8��H
S�e0�+P�=G����=�����	�;�Z���9>�E��1������� @=Ś�:�=A>�90���ֺ�U�|!�=�<��3M���	�RQ�.��=(�O�R= �B= �q;x�Ƚ?R���>>�s?Ƅ?>��d_>?\?��t���`q��$*�?9�
?Х?��'�񥦿�S��PD�6�ƾG�0�ً]>�l�� I~<��ҿj�>g'�>��/�A�?��T�Gp����z^��s?7�� ��]E�'�L�H8Ǿ)�.�>2VǾ�8���'���X��Lb�>�a>e�2�ǉ�>�ſ�þ��I�ž��?�'>p�c���p�M�? *>�$���Xk>�Aξ��=@@Կ"��=�s���O>
�)��ܳ�>z�=w�-�MBw�1�/���N�b��>�K!�/^i��%?k���=W�-1�HJ���6���7�D�=�,B=�.�=���;�u�2�Յ=I�U�N��|=8�V����;m�D=ZU���*e��5�����w[���tM�'ʓ�Ncн��o�N'�=;`������.=�L.�[�_<U�Q�/�7�t�i���?=wr�=e�:<Gk���u>6,;�9�8',�#3�=%���X);�P)�=�� >�'�X0��;��P��<�@�=#�߽,�ڽ��=���=`޻��]Ҏ�D��=��Z �>b�V�/r��Dc:��,��}�C5�c7��x�=L�>��[��x�'�vh��;����=�j=r��,��=U�־S��2&��F��L���f���d�q������Yz�
�B�Vi�s]6>��>�f��ᅿ�����9ڽf�����������!,�[���@~݁��mv>u.�Y�E���5�U��"'��츿9Ŋ=Y:���b��h�z?�i4<+l������{��'��l��5�>6�;X��=&�]��'�!2����=�?Z=M~�=9����{��h��	�����yJ >b��BUX��{�=S��i�*���2�=ߕ���=$ӈ�������F�P_-�6'�N��l��<$��]E�=��ܽM@�<���W��=���jfN=��>�����	�T���O>�����Y�͚=�ݙ;?��Ҽ<�v�C�u��C��z�>����e-�=�n�>(렿�M�IF�=�M��������?���x
��~5)?�[>��
E�b��Qz��J-���
���3�?�y�>�?�%�(��>:�����"����}N=��=�"�����f.=�}&�?���@=�xԋ=��b=�2��
��s.d=|o ���_=נ'���jX����:�_�:o�޽��=��<�w'�oa��D{B=�Ֆ=�����=�ٸ��k�;�x����Q��b��� Cu��n� �<�^>$i=�r��?�����>�=\�Q�y��F<?��-=0���}=�)Q��$N>�<S?�A���J���O�{MN�L�*�.3�<]���4]>(0��w�>�!Ѿ�ӌ>�SԾ+_?C� ��f�Y������ڽc�[�پy"�<��!>։ƽ�M��3���j��m������c�H?'ހ>[6�>ܵ@=�2T�.Ѿhc��eHc�4Co�@?;e�>�`v>�j�B�Z<8��#�5�о&6�>���G>��>�~�>P�>n>`�n�>_��/~�l�����;�RR�P᜿�C>vZ,?���|�(b�����ZZ��Y�'�>��������dY#==��<~	���a���<3��N|����g��,�:��>fa�=P�Ӝ޼W��խ��.�:��=#U�y4>;U+�"��=��<,ď��i=�C�=�S߼A�g�du��(��%^;9=P�A�(#�=	<����΀��uJ>]�#?��W?u&�?a�/?�x�pN(���+�	�M?Wa�>�=. �=�'���V�=6��@�b�_��>�x��!��9=!�S�|>Q�>�'���?8g�<`����	7��p�0*ڿ��:�o�= �>�G?h�M��A ��>��/<-l>CA��?5����L���=�Ո�宼12�v+�=�<Z�0�=�6�=(�-� �*:����>�
���g��[���6�`�<��֢ӼݭQ�K6;n���i��*d�S���
A�~�n���M�����T������7��0N��E�x��<���=i�(�(�C�G���=r�:���]?�c.>,��F*�� >�?�y����ؽe�P���?�/�
1ƽnR^=�>+j�<]W�;���[Ǐ���=�5E������L���Ͼp@�=�`F>q������=�C���+o�;ľ,��<����{��=��>�;��R"޽%�S���ɽQ^�;z���>q�)�jƹ=�)���=��<�ڽ�����%�<xbu=�Rt̽C��<F���(>���w% >�ܦ<��<г�=`:�=s��i=�=��j�i�%��B=S)s< `��#@ɽ4r%����<���K�D=�b?�S���=�#�� �'�"60�5Oֽ���>a�><��=]Fe= ��ta&>��-�s��3���LھWn�=e�Ƚ�s;>1��=@�=�M^=�;�=�W;�p�;�?��jG�1����VT��D�<J���7>>�|'>}���_��I��=�2� .���Խ�>���=�:��K��|=?�S��+�>�n�>��þR~��V�[����zF]����>N��=��u>��|B�</$ھ����{��f>��"�!8>�/�9�3�>�$>��>,�`�����;�i���v�2��I��rP���=��E?WUl�ފ�]/��ə� ~(�       ���