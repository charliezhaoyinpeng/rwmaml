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
qBX   2083194299440qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2084723558496qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2084723559072qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2084723558784q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2084723557248q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2084723556480q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2083194299440qX   2084723556480qX   2084723557248qX   2084723558496qX   2084723558784qX   2084723559072qe.(       �ܛ>�7��M�>�/���o�>KG�>� 2��W��n�=���)d>�d�=���%t ?4�"?���>˄�>$���;$����?�������t�K��>(�0���>��<�%��-��Q���1�D�I���;?:��>_��s�Z�V�	?[@'�B���Ѿ�       8�>(       X�N=f=�=�/�>r�
��}�����C�y1��K�>�͇���������������>��&�	5�>���<3��<�a|�Ke����5���>[�B<�7?���>Z�����>=�<�>*G̼�\�>&�L�X�3�b���/�<C�<3��>EU�r�=��&��Q��(       -�=Ӷѿ��	?�K�*�>�?TW>;v<���=W#
�  !?Y9�>��4?6�0=�IѿJj�=dЗ�0�,?�� ��!�>>8>��Z��z>�$�>�Ϧ>@b�=Y�>l��e͗���>�п��5?�迃�l�c8���>ɮ�If޿ilо�ej�(       Ӭ��5�W�>�]�=��=uVP�ed��y"�Z5Z?�3g>ɐ*>1��o�>-cT=u�d=6:>���E!�f(�<U�i=8*g=�������?�>_6�<���<Ȉa������<霶���=B��>��<��E��A�<�N�<<�J�:S��4�;@      b��;`���	��8����l�?!0�s��R��=8�`��,��E�Ľ��&� ���d%߽�s̽�
��z���`�6|ݽ�t2�[���м�G���b��c3=�Ğ�����B�=�����30>n�{�vȄ�����pɽ�������A>��"�֘�=��=��F�,�������=�!轻Y��u��fd�;b��Ճg�����a��e��
{=Tˣ=T�r=�w��B_�<�tC�x����¼Fă>� �=�n�&G�=����ᾭ���<!i�� ��F�~�������	Y�B����뽢`��(C�<����~�=��>�>�	!��{�=#rO>�����LZ���)<�B��%>I�>.1<�/=B��D_�=l�3���?ߥ2�.W>����`���V����=z��dw��$�+>�� �(f>���>J z="V>���ԕ�=ul�<+���<�=E���4/>^�>�܂�X�ɽ8d\>��!����<r�>�����@�7?��M�V������S��og��9�;T��=�'�=O�=��:���� �s>�1H�<�ݽ^��7El>�L���#>�zL?�.>c��=�$%����;X5����=B��=A�4�׾Ծ2b=HjY�a1��������G���K�(�μN�¼��;;�5߽=3�&�+��>y�
��eM9>5ǐ��M��<��ƽϪ�>]%#>a��<%��M����L*>C���;V��F��>'������=��X>�d�=Y�}>��
�-T�ZlA�8&�`<#��Ӫ���^��O >_�j>6?P��>��K?�PV��% ?�bJ?��x��ž������j�D�Yo`?�,��!���6�_IR�V��<~���C�/��^��\�*?z=�<��j>�j��Ћ?�9?��u�d���r���+X�%T��+�!ݽ������aґ>��^�"J���І�!F�=Њ�h�q?`�E����^?C-������=�޾o7��_�K?,|;�I�]a�퓧>��M��p���A���>�"�� �>H�\�[�>>Em�6V?;��>��,�9'��}+��j��W0��@?=���=!}
=0�>�'�$J����D��w�=s������7ŽF/¼r=۪� e����4�vΊ�h ����_x^=��=a����<�)!�t�Кٻ��Z=��=�|ڽ�
%��#3;�w�@
���>�X����ڼ�eŽ �߼�i=cfM����]�=�i&��#�;�r >��=��=�j�ʣ	��kS?xK�?�+����?�u������2��X#&���>����e?4������-�)�;O�r�?�0]�<��%��<�t�)����&E�>�^��<�@�Zy������?�?ʿ�,�>���<"d�I�a�W���w�n��+���l���I(?�eſ�Z���=��ݗ��H>s�?أɾ���:d��E��?H�i?�'���ޗ��Ϳ�3�=j���[ʾ�1���>�1����=Ouq?�E>%�?� #�Q��2�+���3�_���d_C�9�J�$���'�ž9��<|ξܾ��)8��L�$��(/�:��i�����<�У>I{��]��a�>���<��_����=��־����e�>�]��냾*ҫ��W�5��41�������;=}�>���=��}=S>�=��B�)\�>V���Խ߁?>#y�=0@L�Y˨�ŗb�UB���u^���E< �CY=����B����=^����8�:��&y�=:5��/����=��m�$�<� >�Ȧ� 2;��p =��>:@���K���ʽ!�������=����
��$ ��^�=AD�<F��=��=M����mܽ%��=��=/�㽊F��{ =dBX=�sߺN��� ?�Rؿ iҾ����/H־�u��/�2?{���\3�
5��rT?�?&�g�A앾��.�;��<��c��<�����ӥ;��l����<޺�?NwܽV�)?�t�I�ۿ�A��9-�k��dt����Q>�Ў��Vc���=OF�=l/p�G��9���_ɽ��R>��u=��=�d��Г�=�4a=T=��KM��I�<P�����a=�>�/����=>��K�>���<�� >?:���>��`� =��пY1>r�=�ܼ���H���/=�������>�4��]>�ݻ��/�=��>Q�E��EZ=�	L�z��a�O�eK��\��/��em������U�� r����=�4s�/J=�^ۼ�L���>0(g�(E�K��;�k8�AҜ>�h�r�$<���=z}�=ӧ)����z����F��k+>S�@�>�!>"歼1z<��t>v�="��;^��= '=�:�Y�����A=��Ľ-��>�ᵾ8�G<�G��>A>�������O��=h�|�>���>0W�J�(>4����)�:3�`>e��>�v��tWJ=�i����\<�
��>����7�.���'�"̨����=�lʾW>�4��Ѧ��B`>������2=����;��Z2=�K=ώ�����<4N�<��=� ˽H��m-D������;��7�x�缣��=����災҉"=���BZ��į�h�=��(=Q!��*��H�}�
.5�`̱�ȡ���I�s���B��=pys=L�"�<�=�~:�+���i��������ҽ�Y�<��r�.=��T�X�=Շ�=M'��۾D=O��l�*=�Dv�(������C9��	���>=v�o=�f���Z=0�s�����=�̈=�|=�I=�_ټe��<D�=TU�=Ȩ��d쑽u�9�@_<p�����<��=��X纼4�5�j,����M�|�B�����U��h�<�XP�⧮�:=>T >=��=��=�
��|7����$�nl����6R׽doX>|i���ｖ�>ΐ�=G:P��a�;N��������>�����*<D�h>�<�<�ű>z��d��=B��=��ܽ��W�d��b�~>>�U�R��=���V����=���=&-ֽ^:�1d���b<�UE�T�c��5��C=��}�.I������D=Yh=�ҽ�ԽMa�����#N콷d���=d�1���x=p4>�J���5=�n@��z������<s�B�Lٷ=�xM���^=)�]��6�>�$�=H;?���@�0>�0?r�O�����ռ	����\���a?���ڜ�t �^Y�������н��q����k���\~>�"�0>2�޿�K?z��>�1D��F�=��S�2Z����ɽ'�����9�a��U4��'+�Exb���?d��]9>@���a�=$>8(�*��<��>�:=H�>�f�>��ǿNsp=6&!?B{>i�>�| =����E�>��>���=�	O?5ԛ�����1Ó�v4ٿ��$�We=���>uno��^���g?UÛ>��/=�p�>J�>ܩ?�󋾼,
�B9��� >�7�N�?��P�=Q!j�=���u4��\�ս��<UJ��}޽C��=Hͅ���=�xȽ�	�;a¥�D�3��A�	������H=�Ö��9�=A>-K.���ֺcѽ���=wQ�1y���	�K�K�.��=��L�R= �B=�15���� n�Q�>���?@s�>����?��i�l�����Z��?��ȟ�d���{?����tL����K^��w�~=~Y���'=�g� I~<�Q#�Ϸ?ɂ�>�N�>���?���>������=˹��i��=��E�����9���4��)߾�R>�8�������>����-�U>�޾r�N�9��=E󿽀[�̾A>q�->}�e>��R����=��ľ��}>���=�]?]����=�t��"��=Mv�0m>@�轏ī����>�5�����e�v>�.h��'?]��1vh=��ۼߊ+���+���W�rq���S���Y�D�=��7=>g=�s�;Ux�]� ��>�7�����0��<��Y��$;5�;=�@ټ�Qg��->�H��< G@=�����x
�'ʓ�>l�G�x��o�=�h������.=F���Q�=�%��x�	�D2k��8=��=*~�=i����u>�1<W��8',�X��<%���a);�P)�=�� >�'�����;��x�F<��-=�}�oU���=���=`޻�༬�����=��#�-�>ثV�/r���)>��,��w����YS�������=a��=�u���[��x�'�vh��ɀ����=$��<�g0�/g�=���>����r�.>�y׿��D����qd�$�{�Q��;6$��A̘>�M?��+����=��`���A>6�_>��>��Ⱦ�b�=jH�>[��P:ڿX��=H:*�t������[�v�!�1�0?�a��L�>�8����<=�rY�!��=kg=��]�t�#������A���>�Y���f�=��<$��__��,��=�#�=�|�=�f^�n89;.I��U�Q��>���� jU��y�=?�k�C�*������=��y��=R8��y��o�F��_-��''����m�<ԕ���>��ܽ-9�< ޅ:{��=����gN=H�>g⓿���=IdD��l�=�܀��?��^�z�'=7L��u/�>* �>½����i>����(�=��]>F�i?^�=v��=`lF?����.��1���F��
�~�����+���N��Ґ?"Ug�=(�>�H���:>�h>����]l�<��ۿ�,8��Fw����=��=6���0��}�=�	 �PRH=@=��!�=��b=�,@��v��{2;�A���T=~����;sH����:�*׍<}�g����>r?�!��H��=�t�=�����=Hؗ��k�;t���)��Y� )v:P����ʼ �<�^>$i=pľ5ξ��	��>:hþ�Ƿ�7Z�>e��=埾n�#=�~��=��?���F>���C4o=٤��wM<-L޽�>(0�8c=a�1�!~d>��3����>_���+U�\ＳF$=��L�cn{<��#�THܽW��=�{@�˾|u���B�~|�P�Q<�>�j>%��>���>>����n���'>��=�ʡ>Z8?���j0o>��NC>��>���o\��^�:>QO�=G>��ǾBŕ>�~�=Wɹ>�ڕ?e���6�b:���=��H����dU}>�Ӊ=�sa� ʦ>񐵽��6�	佄Y� G�<�P��z�dY#=
4�=.�ٽ��^���<?���V�p
��:^��,�:3�>fa�=P��SμuH��խ��k+�:��=i���T=#�	�"��=��=[z���B9�&�:��[����e�du��(�㽤��zK�A��A3�v<>��vP�uJ>�o��nj���׽�=<2�9�@�R�9�X��>���;��in=��D���>=�*-����=Jŵ�e#@=�J�=,���!���O�5+׽��J���=7M��8g�<`�����)��p�U���b�+��[�s�%��V >s����A ��>��/<u��=���??�>�}8�|��=8��>�οI�-<g/�=L3��I?A��?��ξ&'>2^�<�/>PG���$�1���=U���p?�n��=f'W;����=��y'?��=ӗܾW�I>%�¾KA��=tG�P�� e��N�e?F7�>���>;�� 8����[��m=x�Ľm���x��T0>�p��Ј>.&2�M�N�Q�U���!�%���
�=��<(P�>���>���Go>����sٿ�g~��Ӿ����D�>~�����>�5�>���<�g�>������+�������=1]�Ó;�Ԓ>��J>R"޽��U�dE���;��A)�=9��O�=��)�Ҟ =R�<�&�x� ���xbu=�;��Rt̽6��<���9��=�w% >�G�<�|��ݱ=N�=�[����=�|���)�#1=Q.< `���hɽ4r%��n�<���m�2=HC��A�S��8���)��\a>d�I��<�K8�%<�=�U�<Ge���a�j���k^>����-�Œ�<=�x8t>5��=u�_=7R�=�;�=�m��8�S=}������Q�>��H��
[<|�5��>�rc>;������l=M�F=�M�fԾ���=���=��\���ڽߖ=La?���WC= ��>��̽P��T�_�׾:K�p= ?���h�P�^��Ƚ���ڨ�{a<yB8��n�=!8>+z,>��4�>Y>s���o;D?gٱ>��ʽ��=r<=�
�Qdk�eI��~	�=�XȽ��G�*C�������ܽ