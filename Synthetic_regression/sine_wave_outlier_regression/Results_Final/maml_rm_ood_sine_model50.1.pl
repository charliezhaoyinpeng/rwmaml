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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2841834733056qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2841834736032qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2841834732096qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2841834730560q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2841834731808q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2841834734688q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2841834730560qX   2841834731808qX   2841834732096qX   2841834733056qX   2841834734688qX   2841834736032qe.(       Se.�`X��D޽H����=�j�=ǒs�oF������[ԑ� ��J�w��TF�:�=���c�4�d��<pC׼,�=�a��M�"�x-V��︽)��=p���>�/�������=�{:�U:+���=Rz��L-μ�"��G�=��=���=����2˼(       .3*����=S���>x����U<��==i<��U=B��=H��m�2����=,JR9�U�z+ὢ��=����f�<i���!��=x(��	̻���m�ý[����p=����_� >�'ݼ�	>�U�J3���16�\sI=p�=�o(=p�<`�L=���@       ~��<�8>m�k=��׻�7$�\_�=�R�=��v�<a+=�T&�w�}=�W=k����E�Ep�=�.�;��?<QBֽ�K=�p@�������==�=�U�=��!=����fB�=�=�0=�6:e/��xe�� �̘�<%�l��=źjH��L�>=P콌*>�J=�����\��>%><��=h8+=n?�@\@���=�}�=�X�b>�:m�=��F��)����]=C�n=�o������ʎ=��P�7_�=�e���Q>�6��$�I>���=v��=��]�-<�=��̽�~�<�O�<-H���[�Ի4��)'<6#�=�w:�l�潉e7��;����=��>6�<���/�=V��=��u��;
���	�j?,>��<l���C�< �?;{�n�$_=r�l��l�=�Y*��\*�a��;6-�"���B��^�=L�����ͽ��=���=*�<,���� ���=y>�R� ��e���"����`�8����=##佐~j�]��X�<@�r;��x=[��.�=��>n1����Ƽר��3ؽ˴�\���X�=��=@&=`	^=����*'�=PϼnV�=3'��`B���f�=�����Ͻj��pѼ1���q>QK=��ǽॳ=���= �n<����:ӽ$~���ʽjq�=���<�_Ž�K¼�a�=>��=�(�Y���={�ͽ�����`>����P��\S<���<�c9��W������q�|Lܽ PD<����<��������=���M=�r��c�<��v=7i��Խ�=�v����֔�=�s3���= Y��<����+$"�J\ཀྵ{)��U=t��W�=(o'�&���C�=/{�<�:5�i�d������=���z=�j���U��.�����=ő1=�� >h.���,�=�8�<��<��8�F G�vt�= �!;���=x~
=��<bZ���<�a�����|I�=)�b�K�����ɽ���W����-=E��= ��=�e�=J��=\�ѽRe�=���=�%6�����- 
��M��%T=�y�=�y���=*�&��>�_��X��=tнgx(�}F޽��=�I��&#=��2< ��]4E��}�qLh<-Ұ=�w�<?Wa�·��SM<�����`�=�� ��`�=F�'�)�<��߇�r�J��= s�<L!&=Qd=��F<=��=��=a�=��'�o�=)y=p�=,�= s3� �=��!��ٳ=�<����Rbb=�߬��9ʼ0!���N��I��!�	=��<�A�=���=1N��k�*�!  =>�`=��.>ʅ����=v�������:=&���)�>�:���ͽ%��=����J��v&����=�;K��=+���8Â�
�<&X�=��0��>�ү���>��a�<x�콣�¼���	�=<���B=�X.�p;�<,�.<@��6�p�i�H?���=v�����=��X�]=������3�1ܕ�n�=%63=P�d<�"n�i<��h�}=:��=����\�����Vc�<5<�=C�U=""�=1������������½Jf�T��= �9��0�2�=m��H�F���&�Psx���C�>P�Z<� �lc	���>�`==S>x��<.�� .��H�����=�ښ���l�.��=X����6=NB�=ɩ>�X��Q���o=�)˽��\��+��,����>!�!>,�.j��  ��`�ý���L�N��oC��/h�g3��֏�=���p�T�}>���=a_��|���J=��+=I�>|���\�=�h>Y����=!�὜h>���;�ʽ�����$<��=  ��(dƽr�=�<�<��� �H<tc=F��=�-ʽra����>��*���)>p�1<� >Ō���w�<��H��S��;�*>����xq����<�q=��>�R+>��:��i׺s�=�}$�lὢ�����>
���=�Խ�X�<�D+=�'�=Oh콊�;�A�= }�<u�=�H\=	�+�5��=S�=>���0�=�@~��Î=7��=f٩�� =�=˘�l��4 �=��ֽ��}=��໛��<|�z������=�.�;@C=�)�uF�=�Kʽ羳=jٹ=�!s=����v膽*x����k�L�2��:jt3��9�=�6�����Խ�1�=)�<
9�=lZǽ��=3!m=�� �4�����Z�F>�&[��V�=n��:�<9S�=)��<���=��=l�p��W���[�<;)��ٜ�/�z����;ڽ��=jü=�9<н��)�x�����F�=¬ >�h��F�=̓X=���-�<���=�.�=�:�	Ш�aC��[���==X�<�~��ӿ�=��>ی�=�g8=i�ͽ'�>o�<�}i����=˳�=�\���=�'�=j�=s�:)�4=�Ǻ����M�
>j�O���>�bŽ�[Y���I=M�Ͻ2�H=�M�=�i��h���E{_�P�*=E�8>�K罉9�j>�_߽Dm�=BE你|ؽ�>�<A��=���TҮ�S��� �=�4<<�c>�!=�,̼�	>�Pg=
����:q=j��~��x��	�<DR4>�ļ�->�S_����vwʽ���=�4��M�=HǽH��0i�y�����۽�,�=F�2����<���=^:⽚K��:��ؗT=`$E=�A����$=H�����>c4��(C=��>B)�=Z5�=p�I<(�=v�̵"�Os�@�C�v?�=�\�� @�7HK:==D�X43����-��8Yݽ���\/=��>�;�+6���D��Y�=h�O=\����ʽ(���$�(MW�&��c�v��aʃ�~�A�G>�k�=�h�=�W�8(�<�#���Ƚ�,:��7�Bu˽�Hƽ)Ǭ��!��d-�=\Hm�GI�hŻ��Cс�t0!���0�{�B�c�>_0�t>� q�L>=&�=G�U��ｼڳ� �;��v�́>��=��� bq=��A=Q=�S�<4�A��v޺:l >Î��蠽���by�[�)�ѥ�=6��=؎�=]��h* �ؽ�Y�*��="�ӽ��,�*����vV=�#�����y9=A��fJ��&�8��T�=��f<��!=F�=��=Z �ƿ�%1���v�*��=f�ٽ;�2�wc�=���=�Ћ����=�����,� ��;�/�=ů!��ݽ���#?���M�[��Vм�/<��V�}�=\7=I�(���o=#���	U�(�<P4=�s�
��i�����<D#�.���L<���=� �
��V�������
�N�o"��V�=�D=����P-���
>��9=�$�=@B��@���ݕ���=�(�=��=,�h�EU�۹��i���m� >�P�= \�;��]��8�� C�<am��� ��'	�̭0=轠ļ�R�8b����=�=ڽr��(�ͽ '�<|�۽��=�=t �ᆧ=���å'���������ݽ���=�`D<��c�Π�=���=��5�(���t��� ��3F�ny�=A�,����f׾=|f=$e��V�<��#��n�=N::�Mݽӷ����= �E�ߍ��򻤽�I�=@��<��R��p=	 U=J��I<�T�=t#H�"Խa>H�E=��;=j0��9N��{!>�������h
�v��4fs=�G�i���[н�M���<�ܽ�i�6˺�X)a��Vܽ�>����u}�<r��=8�ǽ��H�K��<o;>��"��=+�=�xg�y��8;�����=>[�=ưz<��6��T�=%�=� =X�Q=j�)=36�"P<����<�M<B�>�Φ;��=��"���=������=��><�=�k����	>`�½�s=
���{��������"⽇f;����R7A=ۄ=ev�=|�!�r�=��$�ɱ@=�������d�=<�V=��= �:��2�\>�ő�"o�=l����>�X>��= q�<������X½<���=�R�=���'U�R��\ҽND�=�W��L���p��=�ha���;�"����ؽ`h�� ]����=��ӽ�nl�и�=��<�pD;�ʳ���%<�#�x��=� �L"V�r�c=&��8����ٽ@Ғ�4 >��������=����h=qj=�쁽����4>i��=��v�I�޽Y�=,��<��V=�� ��j>��>qP	<���:��Q<��=s�}=T~콯f�<�x^���ν�h����C��r�=�8<)g�=��7=�#�"� >���=�%н�]�o��=κ½��<�ҽ�3=��y��`�Ͻ��m���<��=6V��ߤ����=,��=tؼ�A����<e���ˈǽ�]`=Ȯ?��:���;l�Լ��>"�=c;ϼ9O�<�Z�s[�h�»<�=	�<���&oL=��5�-y�=K&5=���=�{�����=3,�=�=�J��P�@�n��)5��$�;�����W��<Ι�t<��0>_�:z��=Z�$�i�x�`ؽ�=|5�=ڥ+���t;����/=�*�<��>3H�=a<��R�c���+�	���������=s�;;6 L=k�.�-3�o.¼(Tl��6������<{�;�F	�:&�-�E���'=�X8��k���J�<1v=cw����c�=kڋ<
p��[������������{=�1�=:������=���=,g�==,��=	(��h�� �c<���=?�>7�j��>�Vu��7?���M=���4/�=�y>���=�f<B�T�Xls=��=2�=�>�l�=��>���=5��=z���S��=�xȽ�ռ�	��=�<<���w��W������df=G��0C����i!�=�`W=�콨��<��S���������G=J�=��=sƴ=%%�=�<4�=p�׽��ʽ� �t�0�w��=(=�)q���=�E�=g3��%�����s�%��9��V��ڌ<���W�M=�=�������z���3�<��<����=u��R�F<� Z��=���O�����k��<���=P2<pO�����=ZⒽ�m�����=��$>�ϼlyս�p�= P>�\߽U��eT��ǎ���2m��Ͻ_؁<��	C=�>�C ��q�;t��=�x!>���/E=7�=V�>�n[�h���ɽw_Z�e=�|߽8��aa0>�O½+����*9�x�,��Я��Ο==j=��>`�k�аý��<�]�Al	��K����U�9� >���t�콗`<���=(����N�<���=�E�=B>g���¢�=��O����F��<��=�h��(03>�OH<~%�`9ܼ}�a�h6�<���=3�	��K<�=����H��=�͍����=�-$�od�=I@ ���۽S�<��9�=l��<��w�4M>�K��8�콬˒=>2>`�=�\@�H��<-�=�O��)>���<�'g�!.%��L�<�c����=�LY�{2�<�<$��b�=�'�<@n=;��=�]�=�C�<�|�=�\ĽW��=���=UO�����J��=��=G8�o����P�=�G6�}s�����=�R�=y��=�p���%�O?s=1�=Hq�=|�U=�um�=q��Qy��ɀy=z�ƽ�ɿ=Z0�;N�i�.�=���l�4=�e>��B���ݼX��+����� �z<�U���b>�����e�(B�� �<A��F��= ������0� =�ݾ� �<�� �Z�㽢��=x|=.+�=pֵ=�q�=|�=��F�h��#�ܽ��?=����c������=�P�;�h��L�&�.뽝�>��)���=ٶ��s�=����@�� ��8 �˼x�̼�p���1ս��M��� wн`�=<*�= >�Һ�=t�����g=�=����f�=pE̽��5<��\=�c��:,�
��=���o�>*�j���ʼ�����<b7�=��h=G���B�(�Da�=p�V<���:*�q�=�Z�1���g/��z�����=J\�<rן��:/>�?�=���=O�ݽH��� �y=�5=
��1�&>[��plk=�>�T
3�Y�D�G�����=`�>�&�<s�μ83	=צ��qVs=<?$����=:=޽���FC2�E���P�>1�<���p��=���<q1`�����I�>�����&���ȼ�b��B�%>���⽕®=�����ۅ=��&�k�=�B;A*�=��=���=�$���������1{�=w�;x>�y>�S���_�|&>�;>���<��<�	u�����; �̀M=��=3P>(       �������:nQ>�MA��CA��6M��^?o�޾!�$��vd�K|�jg�>d�*�ǟ���1>?hԖ� ���
���,���i�>Ǿ�Fq�P2ý�վ�?���d��zD���m���;�:���X=?�f?O���w�U?8�=h�����8/��B��^D?       ����(       X� �#?a�P>�?����7?���=e�??��c�uCǾ�NϾx#��J�� \�r)���⾺H?�Ҿ����p���??�?eD��:?�͈>�G?f59��1?��E?;A��>�>��+�2hR?��}?�۾/��>Xː�I�
�